# LiftLogger

**LiftLogger** is an iOS application developed using SwiftUI that enables users to effectively plan, track, and record their workouts. The app is designed to support individuals on their fitness journey by offering intuitive features that promote consistency, accountability, and progress tracking.

---

## Features

- Create and manage personalized workout plans across multiple days
- Log individual sets including reps and weight
- Track daily workout completion history
- View progress through a visual calendar interface
- Secure user authentication and data storage via Firebase
- Clean, responsive user interface built with SwiftUI

---

## Prerequisites

To run LiftLogger locally, the following components are required:

- Xcode 15 or higher
- iOS 16.0+ device or simulator
- A configured Firebase project with:
  - Email/Password Authentication
  - Firestore Database

---

## Firebase Configuration

1. Navigate to [Firebase Console](https://console.firebase.google.com)
2. Create a new project
3. Enable Firestore Database and Email/Password Authentication
4. Download the `GoogleService-Info.plist` file
5. Drag the file into the root of your Xcode project
6. Ensure the following is called in `Multipage2App.swift`:

```swift
import Firebase

@main
struct Multipage2App: App {
    @StateObject var exerciseModel = ExerciseModel()
    @StateObject var viewModel: AuthViewModel

    init() {
        FirebaseApp.configure()
        let model = ExerciseModel()
        _exerciseModel = StateObject(wrappedValue: model)
        _viewModel = StateObject(wrappedValue: AuthViewModel(exerciseModel: model))
    }

    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environmentObject(viewModel)
                .environmentObject(exerciseModel)
        }
    }
}

```
---

## Running the App

1. Open the Project in XCode
2. Wait for it to build
3. Cmd + R
4. Wait for the simulator to open


