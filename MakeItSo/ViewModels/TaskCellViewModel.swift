//
//  TaskCellViewModel.swift
//  MakeItSo
//
//  Created by Peter Friese on 13/01/2020.
//  Copyright © 2020 Google LLC. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestoreSwift
import FirebaseFirestore

class TaskCellViewModel: ObservableObject, Identifiable  {
    
    private let taskRepository: TaskRepository
    @Published var task: Task
    
    var id: String {
        task.id ?? ""
    }
    var completionStateIconName: String {
        task.completed ? "checkmark.circle.fill" : "circle"
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var listenerRegistration: ListenerRegistration?
    
    static func newTask() -> TaskCellViewModel {
    TaskCellViewModel(task: Task(title: "", priority: .medium, completed: false))
  }
  
    init(task: Task,repository: TaskRepository = FirestoreTaskRepository()) {
        self.taskRepository = repository
        self.task = task
        
    $task
      .dropFirst()
      .debounce(for: 0.8, scheduler: RunLoop.main)
      .sink { [weak self] task in
        self?.taskRepository.updateTask(task)
      }
      .store(in: &cancellables)
      
      guard let id = task.id else {
          return
      }
      
//        let db = Firestore.firestore()
//        listenerRegistration = db.collection("task").document(id).addSnapshotListener({ snapshot, error in
//            if let task = try? snapshot?.data(as: Task.self) {
//                self.task = task
//            }
//        })
  }

    deinit {
        listenerRegistration?.remove()
    }
  
}
