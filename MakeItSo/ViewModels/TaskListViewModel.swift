//
//  TaskListViewModel.swift
//  MakeItSo
//
//  Created by Peter Friese on 13/01/2020.
//  Copyright © 2020 Google LLC. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

class TaskListViewModel: ObservableObject {
    
    private let taskRepository: TaskRepository
    @Published var taskCellViewModels = [TaskCellViewModel]()
    @Published var userID: String
    
    private var cancellables = Set<AnyCancellable>()
    
    init(userID: String, repository: TaskRepository = FirestoreTaskRepository()) {
        repository.userID = userID
        self.taskRepository = repository
        self.userID = userID

        
        taskRepository.$tasks.map { tasks in
            tasks.map { task in
                TaskCellViewModel(task: task)
            }
        }
        .sink(receiveValue: { [unowned self] models in
            self.taskCellViewModels = models
        })
        .store(in: &cancellables)
    }
    
  func removeTasks(atOffsets indexSet: IndexSet) {
    // remove from repo
    let viewModels = indexSet.lazy.map { self.taskCellViewModels[$0] }
    viewModels.forEach { taskCellViewModel in
      taskRepository.removeTask(taskCellViewModel.task)
    }
  }
  
    func createNewTask() {
        let task = Task(title: "", priority: .medium, completed: false)
        addTask(task: task)
    }
    
  func addTask(task: Task) {
    taskRepository.addTask(task)
  }
    
    //MARK: - preview helper
    
    static func preview() -> TaskListViewModel {
        let viewModel = TaskListViewModel(userID: "")
        viewModel.taskCellViewModels = [TaskCellViewModel(task: Task.example()), TaskCellViewModel(task: Task(id: "2", title: "title", priority: .high, completed: false, createdTime: Timestamp(seconds: 1, nanoseconds: 1), userId: "userID"))]
        return viewModel
    }
    
}
