//
//  ViewThree.swift
//  Multipage
//
//  Created by Troy Deminico on 11/3/24.
//

import SwiftUI

struct ViewThree: View {
    @ObservedObject var exerciseModel: ExerciseModel
    @EnvironmentObject var viewModel: AuthViewModel
    private let apiHandler = ApiHandler()

    private let Muscles = ["Abdominals", "Adductors",   "Biceps",
                             "Calves", "Chest", "Forearms", "Glutes",
                             "Hamstrings","Lats", "Lower_back",
                             "Middle_back", "Neck", "Quadriceps",
                             "Traps", "Triceps" ]

    private var DaysOfWeek: [String] {
            (1...planDays).map { "Day \($0)" }
        }
    
    
    @State private var Exercises: [ExerciseData] = []
    @State private var selectedMuscle: String?
    @State private var selectedExercise: String?
    @State private var planDays: Int = 3
    @State private var selectedDay: String = "Day 1"
    @State private var exerciseToDelete: Exercise?
    @State private var showingDeleteConfirmation: Bool = false
    @State private var refreshExerciseList = false

    private func updateExercisesList() {
        guard let muscle = selectedMuscle else { return }

        apiHandler.fetchExercises(for: muscle) { exercises in
            Exercises = exercises
            selectedExercise = exercises.first?.name
        }
    }

    //remove from the day
    private func deleteExercise() {
        if let exerciseToDelete = exerciseToDelete,
           var dayExercises = exerciseModel.weeklyExercises[selectedDay],
           let indexToDelete = dayExercises.firstIndex(where: { $0.id == exerciseToDelete.id }) {
            dayExercises.remove(at: indexToDelete)
            exerciseModel.weeklyExercises[selectedDay] = dayExercises
            Task {
                await exerciseModel.saveWorkoutPlanToFirebase()
            }
            self.exerciseToDelete = nil
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Create a Workout")
                    .font(.headline)

                Picker("Select Plan Duration", selection: $planDays) {
                    ForEach(3...7, id: \.self) { days in
                        Text("\(days)-Day Plan").tag(days)
                    }
                }
                .tint(.green)
                .padding()
                .onChange(of: planDays){ newPlanDays in
                    exerciseModel.planDays = newPlanDays
                    selectedDay = DaysOfWeek.prefix(newPlanDays).first ?? "Day 1"
                    exerciseModel.setupPlan(for: newPlanDays)
                    refreshExerciseList.toggle()
                                }

                // chose day to update
                Picker("Select Day", selection: $selectedDay) {
                    ForEach(1...exerciseModel.planDays, id: \.self) { dayNumber in
                        Text("Day \(dayNumber)").tag("Day \(dayNumber)")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                //muscles api offers
                DropDown(
                    title: "Muscle",
                    prompt: (selectedMuscle ?? "").isEmpty ? "Select Muscle" : " \(selectedMuscle ?? "")",
                    options: Muscles,
                    width: 500,
                    selection: $selectedMuscle
                )
                // update the exercises to display from api req
                .onChange(of: selectedMuscle) {
                    updateExercisesList()
                }
                .padding()

                VStack(spacing: 10) {
                    ForEach(exerciseModel.weeklyExercises[selectedDay] ?? []) { exercise in
                        HStack {
                            Text(exercise.name)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            Spacer()
                            Button {
                                exerciseToDelete = exercise
                                showingDeleteConfirmation = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // exercises for muscl from api req
                    DropDown(title: "Exercises",
                             prompt: selectedExercise?.isEmpty == false ? selectedExercise! : "Select Exercise",
                             options: Exercises.map { $0.name },
                             width: 500,
                             selection: $selectedExercise)

                    Button("Add Exercise") {
                        if let exerciseData = Exercises.first(where: { $0.name == selectedExercise }) {
                            let newExercise = Exercise(
                                name: exerciseData.name,
                                instructions: exerciseData.instructions,
                                imageName: "\(selectedMuscle ?? "default")image"
                            )
                            exerciseModel.weeklyExercises[selectedDay, default: []].append(newExercise)
                            Task {
                                await exerciseModel.saveWorkoutPlanToFirebase()
                            }
                            print(exerciseModel.weeklyExercises)
                            print("image name -- \(selectedMuscle ?? "default")image")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding()
                    .frame(maxWidth: .infinity)

                    if let exercise = selectedExercise, !exercise.isEmpty {
                        Image("\(selectedMuscle ?? "default")image")
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
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Confirm Delete"),
                message: Text("Are you sure you want to delete \(exerciseToDelete?.name ?? "this exercise") from \(selectedDay)?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteExercise()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            Task {
                await exerciseModel.fetchWorkoutPlanFromFirebase()
            }
        }
    }
}

#Preview {
    ViewThree(exerciseModel: ExerciseModel())
        .environmentObject(AuthViewModel())
}
