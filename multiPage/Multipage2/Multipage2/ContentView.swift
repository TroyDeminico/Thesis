//
//  ContentView.swift
//  Multipage
///Users/troydeminico/Desktop/iosBackup/multiPage/Multipage2/Multipage2/MultiPage.swift
//  Created by Troy Deminico on 11/2/24.
//

import SwiftUI

struct ContentView: View {
    @State private var hasFetchedExercises = false
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @ObservedObject var exerciseModel: ExerciseModel
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            TabView {
                // Home Page Content
                ZStack {
                    Image("dumbbells")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: .infinity)
                        .ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Home Page")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .overlay(
                                    Text("Home Page")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                        .offset(x: 1, y: 1)
                                )
                                .padding(.top, 60)

                            VStack(alignment: .leading, spacing: 10) {
                                // completed day section
                                Text("Completed Days")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                if exerciseModel.completedDaysHistory.isEmpty {
                                    Text("No days completed yet.")
                                        .foregroundColor(.white)
                                } else {
                                    // show the exercises (days) done
                                    ForEach(Array(exerciseModel.completedDaysHistory.enumerated().reversed()), id: \.offset) { index, entry in
                                        let (day, exercises) = entry
                                        // let them be clicked on to see details
                                        NavigationLink(destination: CompletedDayDetailView(day: day, exercises: exercises)) {
                                            Text("\(day) Completed")
                                                .fontWeight(.bold)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.green.opacity(0.7))
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .padding(.horizontal)

                            Spacer(minLength: 60)
                        }
                        .padding(.bottom, 30)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // full screen
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

                // navigation
                // ViewThree Tab
                ViewThree(exerciseModel: exerciseModel)
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Create")
                    }
                // Log Tab
                LogView(exerciseModel: exerciseModel)
                    .tabItem(){
                        Image(systemName: "timer")
                        Text("Log Workout")
                    }
                // Calendar Tab
                WorkoutCalendarView(exerciseModel: exerciseModel)
                    .tabItem(){
                        Image(systemName: "calendar")
                        Text("Calendar")
                    }
                // Profile Tab
                ProfileView()
                    .tabItem {
                        Image(systemName:"person.crop.circle")
                        Text("Profile")
                    }
            }
            .onChange(of: viewModel.userSession) { session in
                if session != nil && !hasFetchedExercises {
                    Task {
                        await exerciseModel.fetchWorkoutPlanFromFirebase()
                        // Update completedDaysHistory after fetching the plan
                        exerciseModel.completedDaysHistory = exerciseModel.weeklyExercises.compactMap { (day, exercises) in
                            let completed = exercises.filter { $0.dateCompleted != nil }
                            return completed.isEmpty ? nil : (day, completed)
                        }
                        hasFetchedExercises = true
                    }
                } else if session == nil {
                    hasFetchedExercises = false // Reset the flag on sign out
                    exerciseModel.completedDaysHistory = [] // Clear history on sign out
                }
            }
        }
    }
}

#Preview {
    let mockAuth = AuthViewModel()
    mockAuth.isAuthenticated = true
    return ContentView(exerciseModel: ExerciseModel())
        .environmentObject(mockAuth)
}
