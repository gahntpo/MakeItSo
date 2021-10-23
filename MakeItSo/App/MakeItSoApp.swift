//
//  MakeItSoApp.swift
//  MakeItSo
//
//  Created by Peter Friese on 30/11/2020.
//  Copyright © 2020 Google LLC. All rights reserved.
//

import SwiftUI
import Firebase

@main
struct MakeItSoApp: App {
  
  @StateObject var authenticationService = AuthenticationService()
  
    
  init() {
    FirebaseApp.configure()
   // authenticationService.signIn()
  }
  
  var body: some Scene {
      WindowGroup {
          if authenticationService.user == nil {
              Text("... loading")
          }else {
              MainView(userID: authenticationService.user?.uid ?? "")
                  .environmentObject(authenticationService)
          }
    }
  }
}
