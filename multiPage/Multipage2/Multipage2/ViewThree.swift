//
//  ViewThree.swift
//  Multipage
//
//  Created by Troy Deminico on 11/3/24.
//

// ViewThree.swift
import SwiftUI

struct ViewThree: View {
    @ObservedObject var exerciseModel: ExerciseModel
    private let apiHandler = ApiHandler()
    
    // muscles supported by API
    private let Muscles = ["Abdominals", "Adductors",   "Biceps",
                           "Calves", "Chest", "Forearms", "Glutes",
                           "Hamstrings","Lats", "Lower_back",
                           "Middle_back", "Neck", "Quadriceps",
                           "Traps", "Triceps" ]
    
    private let DaysOfWeek = ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7"]
    
    // stores the exercises the user chooses
    @State private var Exercises: [ExerciseData] = []
    // the muscle the user chooses from drop down
    @State private var selectedMuscle: String?
    // exercise choses by user
    @State private var selectedExercise: String?
    // the number of days the workout will be 3 is default
    @State private var planDays: Int = 3
    // default to monday for start day
    @State private var selectedDay: String = "Day 1"

    private func updateExercisesList() {
        guard let muscle = selectedMuscle else { return }
        
        // Fetch exercises from the API for the selected muscle
        apiHandler.fetchExercises(for: muscle) { exercises in
                    Exercises = exercises
                    selectedExercise = exercises.first?.name
                }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Create a Workout")
                Text("Create a Workout")
                    .font(.headline)
                
                // allows the user to select the drop down of days they want
                Picker("Select Plan Duration", selection: $planDays) {
                    ForEach(3...7, id: \.self) { days in
                        Text("\(days)-Day Plan").tag(days)
                    }
                }
                //.pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: planDays){
                    exerciseModel.setupPlan(for: planDays)
                    selectedDay = DaysOfWeek.prefix(planDays).first ?? "Day 1"
                }
                
                Picker("Select Day", selection: $selectedDay) {
                    ForEach(DaysOfWeek.prefix(planDays), id:\.self) { day in
                            Text(day).tag(day)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                
                DropDown(
                    title: "Muscle",
                    // checks if selectedMuscle is a valid muscle if it is empty it displays "Select Muscle"
                    prompt: (selectedMuscle ?? "").isEmpty ? "Select Muscle" : " \(selectedMuscle ?? "")",
                    options: Muscles,
                    width: 200,
                    selection: $selectedMuscle
                )
                .onChange(of: selectedMuscle) {
                    // Update the list of exercises based on the selected muscle
                    updateExercisesList()
                }

                
                Button("Add Exercise") {
                    if let exerciseData = Exercises.first(where: { $0.name == selectedExercise }) {
                        let newExercise = Exercise(
                            name: exerciseData.name,
                            instructions: exerciseData.instructions,
                            // temp image API has no image
                            image: Image("placeholderImage")
                        )
                        exerciseModel.weeklyExercises[selectedDay, default: []].append(newExercise)
                    }
                    print(exerciseModel.weeklyExercises)
                }
                .padding()
                
                VStack(spacing: 10) {
                    if let muscle = selectedMuscle {
                        Text(muscle)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }
                    
                    ForEach(exerciseModel.weeklyExercises[selectedDay] ?? []) { exercise in
                            Text(exercise.name)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                    
                    DropDown(title: "Exercises",
                             prompt: selectedExercise?.isEmpty == false ? selectedExercise! : "Select Exercise",
                             options: Exercises.map { $0.name },
                             width: 150,
                             selection: $selectedExercise)
                    
                    if let exercise = selectedExercise, !exercise.isEmpty {
                        Image("temppushup")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding()
                    } else {
                        Text("Select an exercise to view image")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
        }
    }
}


#Preview {
    ViewThree(exerciseModel: ExerciseModel())
}
