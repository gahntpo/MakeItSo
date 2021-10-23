# MakeItSo
Review Firestore with SwiftUI demo project

- data flow with Firebase
- snapshot listeners
- exchange data between multiple ViewModels
- MVVM with Repository
- authentication with Firebase

### Review Video on my Youtube channel



### Original project is from the Firebase Youtube channel
- [Building a to-do list app with SwiftUI and Firebase (Part 1)](https://www.youtube.com/watch?v=4RUeW5rUcww&list=PLl-K7zZEsYLkTjfUJvjiPZ14F5c81uDuN)
- [Build a to-do list app w/ SwiftUI & Firebase - Pt 2: Firestore & Anonymous Auth](https://www.youtube.com/watch?v=HDde7TqKCpk)
- [Build a to-do list app w/ SwiftUI & Firebase - Pt 3: Sign in with Apple](https://www.youtube.com/watch?v=6iTmteRd07Q) 

[repository](https://github.com/peterfriese/MakeItSo)


# Setup
- clone project
- install pods
- create Firebase iOS app, add GoogleService-Info.plist
- setup Firebase Firestore
- add index query: Firebase Database > Indexes > Composite - add Index (Collection ID: tasks, Fields Indexed: userId and createdTime)
- setup Firebase Authentication: anonymously and SignInWithApple
