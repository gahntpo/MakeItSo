//
//  TaskCell.swift
//  MakeItSo
//
//  Created by Karin Prater on 19.10.21.
//  Copyright © 2021 Google LLC. All rights reserved.
//

import SwiftUI

enum InputError: Error {
  case empty
}

struct TaskCell: View {
  @ObservedObject var taskCellVM: TaskCellViewModel
  var onCommit: (Result<Task, InputError>) -> Void = { _ in }
  
  var body: some View {
    HStack {
      Image(systemName: taskCellVM.completionStateIconName)
        .resizable()
        .frame(width: 20, height: 20)
        .onTapGesture {
          self.taskCellVM.task.completed.toggle()
        }
      TextField("Enter task title", text: $taskCellVM.task.title,
                onCommit: {
                  if !self.taskCellVM.task.title.isEmpty {
                    self.onCommit(.success(self.taskCellVM.task))
                  }
                  else {
                    self.onCommit(.failure(.empty))
                  }
      })
            .id(taskCellVM.id)
        
    }
  }
}

struct TaskCell_Previews: PreviewProvider {
    static var previews: some View {
        TaskCell(taskCellVM: TaskCellViewModel(task: Task.example()))
            .previewLayout(.fixed(width: 200, height: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/))
    }
}
