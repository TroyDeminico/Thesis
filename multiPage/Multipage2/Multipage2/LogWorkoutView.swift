import SwiftUI

struct LogWorkoutView: View {
    @ObservedObject var exerciseModel: ExerciseModel
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Workout Plan")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                // check if there are any exercises to display
                if exerciseModel.weeklyExercises.isEmpty {
                    Text("No exercises added to the plan.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // iterate through the days
                    ForEach(Array(exerciseModel.weeklyExercises.keys.sorted()), id: \.self) { day in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(day)
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            // display exercises for the day
                            if let exercises = exerciseModel.weeklyExercises[day], !exercises.isEmpty {
                                ForEach(exercises) { exercise in
                                    HStack(alignment: .center) {
                                        exercise.image
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .padding(.trailing, 8)
                                        
                                        VStack(alignment: .leading) {
                                            Text(exercise.name)
                                                .font(.subheadline)
                                                .bold()
                                            
                                            Text("\(exercise.sets) sets of \(exercise.reps) reps")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            } else {
                                Text("No exercises added for this day.")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            print("LogWorkoutView weeklyExercises: \(exerciseModel.weeklyExercises)")
        }
    }
}

#Preview {
    LogWorkoutView(exerciseModel: ExerciseModel())
}
