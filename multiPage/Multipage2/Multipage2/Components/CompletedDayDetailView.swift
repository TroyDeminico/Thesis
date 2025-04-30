//
//  CompletedDayDetailView.swift
//  Multipage2
//
//  Created by Troy Deminico on 4/10/25.
//

import SwiftUI

struct CompletedDayDetailView: View {
    let day: String
    let exercises: [Exercise]

    var body: some View {
        // displayed on the home page after user completes a workout
        VStack(alignment: .leading, spacing: 16) {
            Text("\(day) Completed Workouts")
                .font(.title)
                .bold()
                .padding(.top)

            if exercises.isEmpty {
                Text("No exercises completed for \(day).")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(exercises) { exercise in
                    VStack(alignment: .leading) {
                        Text(exercise.name)
                            .font(.headline)

                        if let date = exercise.dateCompleted {
                            Text("Completed on: \(date.formatted(date: .abbreviated, time: .shortened))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        if exercise.setDetails.isEmpty {
                            Text("Sets: \(exercise.sets), Reps: \(exercise.reps), Weight: \(exercise.weight)")
                                .font(.subheadline)
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Logged Sets:")
                                    .font(.subheadline)
                                    .bold()
                                ForEach(exercise.setDetails.indices, id: \.self) { index in
                                    let set = exercise.setDetails[index]
                                    Text("Set \(index + 1): \(set.reps) reps, \(set.weight) lbs")
                                        .font(.subheadline)
                                }
                            }
                        }

                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle(day)
    }
}
