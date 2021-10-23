//
//  TaskListView.swift
//  MakeItSo
//
//  Created by Karin Prater on 19.10.21.
//  Copyright © 2021 Google LLC. All rights reserved.
//

import SwiftUI

struct TaskListView: View {
    
    @ObservedObject var taskListVM: TaskListViewModel
        
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach (taskListVM.taskCellViewModels) { taskCellVM in
                    TaskCell(taskCellVM: taskCellVM)
                }
                .onDelete { indexSet in
                    self.taskListVM.removeTasks(atOffsets: indexSet)
                }
            }
            .listStyle(PlainListStyle())
            Button(action: {
                taskListVM.createNewTask()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("New Task")
                }
            }
            .padding()
            .accentColor(Color(UIColor.systemRed))
        }

    }
}


struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(taskListVM: TaskListViewModel.preview())
    }
}
