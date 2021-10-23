//
//  TestDataTaskRepository.swift
//  MakeItSo
//
//  Created by Karin Prater on 23.10.21.
//  Copyright © 2021 Google LLC. All rights reserved.
//

import Foundation

class TestDataTaskRepository: BaseTaskRepository, TaskRepository, ObservableObject {
  override init() {
    super.init()
    self.tasks = testDataTasks
  }
  
  func addTask(_ task: Task) {
    tasks.append(task)
  }
  
  func removeTask(_ task: Task) {
    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
      tasks.remove(at: index)
    }
  }
  
  func updateTask(_ task: Task) {
    if let index = self.tasks.firstIndex(where: { $0.id == task.id } ) {
      self.tasks[index] = task
    }
  }
}
