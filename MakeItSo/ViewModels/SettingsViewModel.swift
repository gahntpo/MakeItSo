//
//  SettingsViewModel.swift
//  MakeItSo
//
//  Created by Peter Friese on 19/02/2020.
//  Copyright © 2020 Google LLC. All rights reserved.
//

import Foundation
import Combine
import Firebase

class SettingsViewModel: ObservableObject {
  @Published var user: User?
  @Published var isAnonymous = true
  @Published var email: String = ""
  @Published var displayName: String = ""
  
  private let authenticationService: AuthenticationService
  
    private var cancellables = Set<AnyCancellable>()
    
    init(authenticationService: AuthenticationService) {
        self.authenticationService = authenticationService
        
        authenticationService.$user.compactMap { user in
            user?.isAnonymous
        }
        .assign(to: \.isAnonymous, on: self)
        .store(in: &cancellables)
        
        authenticationService.$user.compactMap { user in
            user?.email
        }
    .assign(to: \.email, on: self)
    .store(in: &cancellables)
    
    authenticationService.$user.compactMap { user in
      user?.displayName
    }
    .assign(to: \.displayName, on: self)
    .store(in: &cancellables)

  }
  
  func logout() {
    self.authenticationService.signOut()
  }
  
}

