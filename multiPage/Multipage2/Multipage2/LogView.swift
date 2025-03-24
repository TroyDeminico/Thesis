import SwiftUI

struct LogView: View {
    @ObservedObject var exerciseModel: ExerciseModel
    @State private var currentDay: String = "Day 1"
    @State private var currentExerciseIndex: Int = 0
    @State private var currentSet: Int = 1
    @State private var workoutComplete: Bool = false

    var body: some View {
        VStack {
            Text("Workout Log")
                .font(.largeTitle)
                .bold()
                .padding()

            if workoutComplete {
                Text("Workout Complete! ✅")
                    .font(.title)
                    .foregroundColor(.green)
                    .padding()
            } else if let exercises = exerciseModel.weeklyExercises[currentDay], currentExerciseIndex < exercises.count {
                let exercise = exercises[currentExerciseIndex]
                
                VStack(spacing: 16) {
                    Text("Current Exercise:")
                        .font(.headline)
                    
                    Text(exercise.name)
                        .font(.title2)
                        .bold()
                    
                    
                    exercise.image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(10)
                    
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
                }
                .padding()
            } else {
                Text("No exercises for today. Rest or pick a different day.")
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            if exerciseModel.weeklyExercises.isEmpty {
                workoutComplete = true
            }
        }
    }

    // MARK: - Log Workout Progress
    func logSet() {
        guard let exercises = exerciseModel.weeklyExercises[currentDay], currentExerciseIndex < exercises.count else {
            workoutComplete = true
            return
        }
        
        let currentExercise = exercises[currentExerciseIndex]

        if currentSet < currentExercise.sets {
            currentSet += 1
        } else {
            // Move to next exercise
            currentExerciseIndex += 1
            currentSet = 1
        }

        // If all exercises are done, mark the workout complete
        if currentExerciseIndex >= exercises.count {
            workoutComplete = true
        }
    }
}

#Preview {
    LogView(exerciseModel: ExerciseModel())
}
