//
//  ContentView.swift
//  MakeItSo
//
//  Created by Peter Friese on 10/01/2020.
//  Copyright © 2020 Google LLC. All rights reserved.
//

import SwiftUI

struct MainView: View {

    init(userID: String) {
        let taskVM = TaskListViewModel(userID: userID)
        self._taskListVM = StateObject(wrappedValue: taskVM)
    }
    
    @State var showSettingsScreen = false
    
    @StateObject var taskListVM: TaskListViewModel
    @EnvironmentObject var auth: AuthenticationService
    
    var body: some View {
        NavigationView {
            TaskListView(taskListVM: taskListVM)
            
                .navigationBarItems(trailing:
                                        Button(action: {
                    self.showSettingsScreen.toggle()
                }) {
                    Image(systemName: "gear")
                }
                )
                .navigationBarTitle("Tasks")
                .sheet(isPresented: $showSettingsScreen) {
                    SettingsView(settingsViewModel: SettingsViewModel(authenticationService: auth))
                        .environmentObject(auth)
            }
    }
//        .onReceive(auth.$user) { user in
//            taskListVM.userID = user?.uid ?? ""
//        }
        
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
      MainView(userID: "userID")
          .environmentObject(AuthenticationService())
  }
}



