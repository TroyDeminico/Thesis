//LogWorkoutView
// really view plan


import SwiftUI

struct LogWorkoutView: View {
    @ObservedObject var exerciseModel: ExerciseModel
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Workout Plan")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)

                    if exerciseModel.weeklyExercises.isEmpty {
                        // if empty plan
                        Text("No exercises added to the plan.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(Array(exerciseModel.weeklyExercises.keys.sorted()), id: \.self) { day in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(day)
                                    .font(.headline)

                                if let exercises = exerciseModel.weeklyExercises[day], !exercises.isEmpty {
                                    // show the plan for each day in detail
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
        }
        .navigationTitle("Workout Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .labelStyle(TitleOnlyLabelStyle())
                }
            }
        }
        .onAppear {
            Task {
                await exerciseModel.fetchWorkoutPlanFromFirebase()
            }
        }
    }
}


#Preview {
    LogWorkoutView(exerciseModel: ExerciseModel())
        .environmentObject(AuthViewModel())
}
