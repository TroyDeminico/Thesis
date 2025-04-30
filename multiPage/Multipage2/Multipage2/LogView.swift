import SwiftUI

struct LogView: View {
    @ObservedObject var exerciseModel: ExerciseModel
    @State private var currentDay: String = ""
    @State private var currentExerciseIndex: Int = 0
    @State private var currentSet: Int = 1
    @State private var workoutComplete: Bool = false
    @State private var showInfo: Bool = false
    @State private var repsInput: String = ""
    @State private var weightInput: String = ""
    @State private var hasLoaded: Bool = false
    @EnvironmentObject var viewModel: AuthViewModel

    var selectableDays: [String] {
        // default days 
        let daysOfWeek = ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7"]
        return Array(exerciseModel.weeklyExercises.keys).sorted().filter { day in
            daysOfWeek.prefix(exerciseModel.planDays).contains(day)
        }
    }

    var body: some View {
        VStack {
            Text("Workout Log")
                .font(.largeTitle)
                .bold()
                .padding(.bottom)
            if !selectableDays.isEmpty {
                // choose day to do
                Picker("Select Day", selection: $currentDay) {
                    ForEach(selectableDays, id: \.self) { day in
                        Text(day).tag(day)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: currentDay) { _ in
                    currentExerciseIndex = 0
                    currentSet = 1
                    workoutComplete = (exerciseModel.weeklyExercises[currentDay]?.isEmpty ?? true)
                    // Reset input fields when the day changes
                    if let exercises = exerciseModel.weeklyExercises[currentDay], let firstExercise = exercises.first {
                        // the reps and weight for workout input as default vals
                        repsInput = String(firstExercise.reps)
                        weightInput = String(firstExercise.weight)
                    } else {
                        repsInput = ""
                        weightInput = ""
                    }
                }
                .onAppear {
                    if currentDay.isEmpty, let firstDay = selectableDays.first {
                        currentDay = firstDay
                        workoutComplete = (exerciseModel.weeklyExercises[currentDay]?.isEmpty ?? true)
                        // Set initial input fields
                        if let exercises = exerciseModel.weeklyExercises[currentDay], let firstExercise = exercises.first {
                            repsInput = String(firstExercise.reps)
                            weightInput = String(firstExercise.weight)
                        }
                    }
                }
            } else {
                Text("No workout plan created yet.")
                    .foregroundColor(.gray)
                    .padding()
            }

            if workoutComplete {
                Text("Workout Completed, Select New Day!")
                    .font(.title)
                    .foregroundColor(.green)
                    .padding()
            } else if let exercises = exerciseModel.weeklyExercises[currentDay], currentExerciseIndex < exercises.count {
                let exercise = exercises[currentExerciseIndex]

                VStack(spacing: 16) {
                    // teh info for current exercise displayed
                    Text("Current Exercise:")
                        .font(.headline)

                    Text(exercise.name)
                        .font(.title2)
                        .bold()

                    Image(exercise.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .cornerRadius(10)

                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Reps")
                                .font(.headline)
                            TextField("Enter reps", text: $repsInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .onChange(of: repsInput) { newValue in
                                    if let newReps = Int(newValue) {
                                        exerciseModel.weeklyExercises[currentDay]?[currentExerciseIndex].reps = newReps
                                        Task {
                                            await exerciseModel.saveWorkoutPlanToFirebase()
                                        }
                                    }
                                }
                        }

                        VStack(alignment: .leading) {
                            Text("Weight")
                                .font(.headline)
                            TextField("Enter weight", text: $weightInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                            // update on baceknd weight
                                .onChange(of: weightInput) { newValue in
                                    if let newWeight = Int(newValue) {
                                        exerciseModel.weeklyExercises[currentDay]?[currentExerciseIndex].weight = newWeight
                                        Task {
                                            await exerciseModel.saveWorkoutPlanToFirebase()
                                        }
                                    }
                                }
                        }
                    }

                    HStack {
                        Spacer()
                        Button(action: {
                            showInfo = true
                        }) {
                            // info for the exercise dispalyed after clicked
                            Image(systemName: "info.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $showInfo) {
                            VStack(spacing: 20) {
                                Text("Workout Info")
                                    .font(.title)
                                    .bold()
                                Text("Instructions:")
                                    .font(.headline)
                                Text(exercise.instructions)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                Text("Reps: \(exercise.reps) • Sets: \(exercise.sets) • Weight: \(exercise.weight)")
                                Button("Close") {
                                    showInfo = false
                                }
                                .padding()
                            }
                            .padding()
                        }
                    }

                    Text("Set \(currentSet) of \(exercise.sets)")
                        .font(.headline)
                        .padding()

                    Button(action: logSet) {
                        Text("Log Set")
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    if !exercise.setDetails.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Logged Sets:")
                                .font(.headline)
                            ForEach(exercise.setDetails.indices, id: \.self) { index in
                                let set = exercise.setDetails[index]
                                Text("Set \(index + 1): \(set.reps) reps, \(set.weight) lbs")
                                    .font(.subheadline)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .padding()
                .onAppear {
                    // Set input fields when the current exercise changes
                    repsInput = String(exercise.reps)
                    weightInput = String(exercise.weight)
                }
            } else if !selectableDays.isEmpty {
                Text("No exercises for \(currentDay).")
                    .foregroundColor(.gray)
            } else {
                // Already handled the case where selectableDays is empty
            }

            Spacer()
        }
        .padding()
        .onAppear {
            guard !hasLoaded else { return }
            hasLoaded = true
            Task {
                await exerciseModel.fetchWorkoutPlanFromFirebase()
                if currentDay.isEmpty, let firstDay = selectableDays.first {
                    currentDay = firstDay
                    workoutComplete = (exerciseModel.weeklyExercises[currentDay]?.isEmpty ?? true)
                    // Set initial input fields after fetching
                    if let exercises = exerciseModel.weeklyExercises[currentDay], let firstExercise = exercises.first {
                        repsInput = String(firstExercise.reps)
                        weightInput = String(firstExercise.weight)
                    }
                }
            }
        }
    }

    func logSet() {
        guard var exercises = exerciseModel.weeklyExercises[currentDay], currentExerciseIndex < exercises.count else {
            workoutComplete = true
            return
        }

        var currentExercise = exercises[currentExerciseIndex]

        // record individual set
        let reps = Int(repsInput) ?? currentExercise.reps
        let weight = Int(weightInput) ?? currentExercise.weight
        let newSet = ExerciseSet(reps: reps, weight: weight)
        currentExercise.setDetails.append(newSet)

        // save the set progress
        exercises[currentExerciseIndex] = currentExercise
        exerciseModel.weeklyExercises[currentDay] = exercises

        if currentSet < currentExercise.sets {
            currentSet += 1
        } else {
            // Finalize the exercise
            currentExercise.dateCompleted = Date()
            exercises[currentExerciseIndex] = currentExercise
            exerciseModel.weeklyExercises[currentDay] = exercises
            exerciseModel.addRecentWorkout(currentExercise)
            currentExerciseIndex += 1
            currentSet = 1
        }

        if currentExerciseIndex >= exercises.count {
            workoutComplete = true

            // Finalize and store the day’s exercises with date
            let completedExercises = exercises.map { exercise in
                var updated = exercise
                updated.dateCompleted = Date()
                return updated
            }

            exerciseModel.completedDaysHistory.append((currentDay, completedExercises))

            // Clear setDetails after saving
            let resetExercises = completedExercises.map { exercise in
                var reset = exercise
                reset.setDetails = []
                return reset
            }

            exerciseModel.weeklyExercises[currentDay] = resetExercises
            completedExercises.forEach { exerciseModel.addRecentWorkout($0) }

            Task {
                await exerciseModel.saveWorkoutPlanToFirebase()
            }
        }
    }
}

#Preview {
    LogView(exerciseModel: ExerciseModel())
        .environmentObject(AuthViewModel())
}
