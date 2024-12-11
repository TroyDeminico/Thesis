//
//  Multipage2App.swift
//  Multipage2
//
//  Created by Troy Deminico on 11/17/24.
//

import SwiftUI

@main
struct Multipage2App: App {
    @StateObject var exerciseModel = ExerciseModel()

    var body: some Scene {
        WindowGroup {
            ContentView(exerciseModel: exerciseModel)
        }
    }
}


