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
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environmentObject(viewModel)
                .environmentObject(exerciseModel)
        }
    }
}


