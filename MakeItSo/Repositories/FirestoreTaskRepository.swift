//
//  FirestoreTaskRepository.swift
//  MakeItSo
//
//  Created by Karin Prater on 17.10.21.
//  Copyright © 2021 Google LLC. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFunctions

import Combine

class FirestoreTaskRepository: BaseTaskRepository, TaskRepository, ObservableObject {
    private let db = Firestore.firestore()
    private let functions = Functions.functions()
  var tasksPath: String = "tasks"
  
  private var listenerRegistration: ListenerRegistration?
  private var cancellables = Set<AnyCancellable>()
  
  override init() {
    super.init()
    
    // (re)load data if user changes
      $userID
          .receive(on: DispatchQueue.main)
          .sink { [weak self] user in
              self?.loadData()
          }
          .store(in: &cancellables)
  }

  private func loadData() {
    if listenerRegistration != nil {
      listenerRegistration?.remove()
    }
    listenerRegistration = db.collection(tasksPath)
      .whereField("userId", isEqualTo: self.userID)
      .order(by: "createdTime")
      .addSnapshotListener { (querySnapshot, error) in
        if let querySnapshot = querySnapshot {
          self.tasks = querySnapshot.documents.compactMap { document -> Task? in
            try? document.data(as: Task.self)
          }
        }
      }
  }
  
  func addTask(_ task: Task) {
    do {
      var userTask = task
      userTask.userId = self.userID
      let _ = try db.collection(tasksPath).addDocument(from: userTask)
    }
    catch {
      fatalError("Unable to encode task: \(error.localizedDescription).")
    }
  }
  
  func removeTask(_ task: Task) {
    if let taskID = task.id {
      db.collection(tasksPath).document(taskID).delete { (error) in
        if let error = error {
          print("Unable to remove document: \(error.localizedDescription)")
        }
      }
    }
  }
  
  func updateTask(_ task: Task) {
    if let taskID = task.id {
      do {
        try db.collection(tasksPath).document(taskID).setData(from: task)
      }
      catch {
        fatalError("Unable to encode task: \(error.localizedDescription).")
      }
    }
  }
  
  func migrateTasks(from idToken: String) {
    let parameters = ["idToken": idToken]
    functions.httpsCallable("migrateTasks").call(parameters) { (result, error) in
      if let error = error as NSError? {
        print("Error: \(error.localizedDescription)")
      }
      print("Function result: \(result?.data ?? "(empty)")")
    }
  }
}
