//
//  Multipage2App.swift
//  Multipage2
//
//  Created by Troy Deminico on 11/17/24.
//

import SwiftUI
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


