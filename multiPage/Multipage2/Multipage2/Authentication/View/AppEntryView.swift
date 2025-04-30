//
//  AppEntryView.swift
//  Multipage2
//
//  Created by Troy Deminico on 3/22/25.
//

import SwiftUI

struct AppEntryView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var exerciseModel: ExerciseModel

    var body: some View {
        if viewModel.isAuthenticated || viewModel.userSession != nil {
            ContentView(exerciseModel: exerciseModel) // pass the injected instance
        } else {
            LoginView()
        }
    }
}

#Preview {
    AppEntryView()
        .environmentObject(AuthViewModel())
        .environmentObject(ExerciseModel())
}
