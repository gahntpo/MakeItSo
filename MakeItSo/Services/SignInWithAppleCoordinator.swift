//
//  SignInWithAppleCoordinator.swift
//  MakeItSo
//
//  Created by Karin Prater on 23.10.21.
//  Copyright © 2021 Google LLC. All rights reserved.
//


import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class SignInWithAppleCoordinator: NSObject {
    
    @Published private var authenticationService: AuthenticationService
    
    private weak var window: UIWindow!
    private var onSignedInHandler: ((User) -> Void)?
    
    private var currentNonce: String?
    
    init(window: UIWindow?, auth: AuthenticationService) {
        self.window = window
        self.authenticationService = auth
    }
    
    private func appleIDRequest(withState: SignInState) -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    request.state = withState.rawValue
    
    let nonce = randomNonceString()
    currentNonce = nonce
    request.nonce = sha256(nonce)
    
    return request
  }

  func signIn(onSignedInHandler: @escaping (User) -> Void) {
    self.onSignedInHandler = onSignedInHandler
    
    let request = appleIDRequest(withState: .signIn)

    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
  }
  
  func link(onSignedInHandler: @escaping (User) -> Void) {
    self.onSignedInHandler = onSignedInHandler
    
    let request = appleIDRequest(withState: .link)
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
  }

}


extension SignInWithAppleCoordinator: ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
        return
      }
      guard let stateRaw = appleIDCredential.state, let state = SignInState(rawValue: stateRaw) else {
        print("Invalid state: request must be started with one of the SignInStates")
        return
      }
      
      let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                idToken: idTokenString,
                                                rawNonce: nonce)

      switch state {
      case .signIn:
        Auth.auth().signIn(with: credential) { (result, error) in
          if let error = error {
            print("Error authenticating: \(error.localizedDescription)")
            return
          }
          if let user = result?.user {
            if let onSignedInHandler = self.onSignedInHandler {
              onSignedInHandler(user)
            }
          }
        }
      case .link:
        if let currentUser = Auth.auth().currentUser {
          currentUser.link(with: credential) { (result, error) in
            if let error = error, (error as NSError).code == AuthErrorCode.credentialAlreadyInUse.rawValue {
              print("The user you're signing in with has already been linked, signing in to the new user and migrating the anonymous users [\(currentUser.uid)] tasks.")
              
              if let updatedCredential = (error as NSError).userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? OAuthCredential {
                print("Signing in using the updated credentials")
                Auth.auth().signIn(with: updatedCredential) { (result, error) in
                  if let user = result?.user {
                    currentUser.getIDToken { (token, error) in
                      if let idToken = token {
                      //  (self.taskRepository as? FirestoreTaskRepository)?.migrateTasks(from: idToken)
                        self.doSignIn(appleIDCredential: appleIDCredential, user: user)
                      }
                    }
                  }
                }
              }
            }
            else if let error = error {
              print("Error trying to link user: \(error.localizedDescription)")
            }
            else {
              if let user = result?.user {
                self.doSignIn(appleIDCredential: appleIDCredential, user: user)
              }
            }
          }
        }
      case .reauth:
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (result, error) in
          if let error = error {
            print("Error authenticating: \(error.localizedDescription)")
            return
          }
          if let user = result?.user {
            self.doSignIn(appleIDCredential: appleIDCredential, user: user)
          }
        })
      }
    }
  }
  
  private func doSignIn(appleIDCredential: ASAuthorizationAppleIDCredential, user: User) {
    if let fullName = appleIDCredential.fullName {
      if let givenName = fullName.givenName, let familyName = fullName.familyName {
        let displayName = "\(givenName) \(familyName)"
        self.authenticationService.updateDisplayName(displayName: displayName) { result in
          switch result {
          case .success(let user):
            print("Succcessfully update the user's display name: \(String(describing: user.displayName))")
          case .failure(let error):
            print("Error when trying to update the display name: \(error.localizedDescription)")
          }
          self.callSignInHandler(user: user)
        }
      }
      else {
        self.callSignInHandler(user: user)
      }
    }
  }
  
  private func callSignInHandler(user: User) {
    if let onSignedInHandler = self.onSignedInHandler {
      onSignedInHandler(user)
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    print("Sign in with Apple errored: \(error.localizedDescription)")
  }
  
}

extension SignInWithAppleCoordinator: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.window
  }
}


// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
private func randomNonceString(length: Int = 32) -> String {
  precondition(length > 0)
  let charset: Array<Character> =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remainingLength = length

  while remainingLength > 0 {
    let randoms: [UInt8] = (0 ..< 16).map { _ in
      var random: UInt8 = 0
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
      if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
      }
      return random
    }

    randoms.forEach { random in
      if remainingLength == 0 {
        return
      }

      if random < charset.count {
        result.append(charset[Int(random)])
        remainingLength -= 1
      }
    }
  }

  return result
}

@available(iOS 13, *)
private func sha256(_ input: String) -> String {
  let inputData = Data(input.utf8)
  let hashedData = SHA256.hash(data: inputData)
  let hashString = hashedData.compactMap {
    return String(format: "%02x", $0)
  }.joined()

  return hashString
}
