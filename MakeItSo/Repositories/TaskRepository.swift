//
//  TaskRepository.swift
//  MakeItSo
//
//  Created by Peter Friese on 14/01/2020.
//  Copyright © 2020 Google LLC. All rights reserved.
//

import Foundation

class BaseTaskRepository {
    @Published var tasks = [Task]()
    @Published var userID: String? = nil
}

protocol TaskRepository: BaseTaskRepository {
  func addTask(_ task: Task)
  func removeTask(_ task: Task)
  func updateTask(_ task: Task)
}


