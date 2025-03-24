//
//  ContentView.swift
//  Multipage
///Users/troydeminico/Desktop/iosBackup/multiPage/Multipage2/Multipage2/MultiPage.swift
//  Created by Troy Deminico on 11/2/24.
//

import SwiftUI

struct ContentView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @ObservedObject var exerciseModel: ExerciseModel

    var body: some View {
        NavigationView {
            TabView {
                // Home Page Content
                ZStack {
                    // background Image no image in currently
                    Image("dumbbells")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea() // image will fill screen

                    VStack {
                        // header is centered
                        Text("Home Page")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 20)
                        
                

                        VStack(spacing: 15) {
                            // temo text field
                            TextField("First Name", text: $firstName)
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .frame(maxWidth: 350)  // set max width for larger screens
                                .frame(height: 60)
                                .padding(.horizontal)
                            
                            // temp text field
                            TextField("Last Name", text: $lastName)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .frame(maxWidth: 350)
                                .frame(height: 60)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Recent Workouts Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent Workouts")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.top, 20)
                            
                            if exerciseModel.recentWorkouts.isEmpty {
                                Text("No recent workouts")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(exerciseModel.recentWorkouts.reversed()) { workout in
                                    WorkoutBox(workout: workout)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal)

                        Spacer() // Pushes content upwards
                    }
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

                // ViewThree Tab
                ViewThree(exerciseModel: exerciseModel)
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Create")
                    }
                LogWorkoutView(exerciseModel: exerciseModel)
                    .tabItem(){
                        Image(systemName: "eye")
                        Text("View")
                    }
                LogView(exerciseModel: exerciseModel)
                    .tabItem(){
                        Image(systemName: "timer")
                        Text("Log")
                    }
                ProfileView()
                    .tabItem {
                        Image(systemName:"person.crop.circle")
                        Text("Profile")
                        }
            }
        }
    }
}


struct WorkoutBox: View {
    let workout: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(workout.name)
                .font(.headline)
                .foregroundColor(.white)
            
            if let date = workout.dateCompleted {
                Text(date, style: .date) // Show date if available
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                Text("Not completed yet") // Display alternative text
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            
            Text("Sets: \(workout.sets) • Reps: \(workout.reps)")
                .font(.body)
                .foregroundColor(.white)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.8)))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    ContentView(exerciseModel: ExerciseModel())
}
