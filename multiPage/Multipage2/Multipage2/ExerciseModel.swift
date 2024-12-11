//
//  ExerciseModel.swift
//  Multipage
//
//  Created by Troy Deminico on 11/4/24.
//

import Foundation
import SwiftUI

struct Exercise: Identifiable {
    var id = UUID()
    var name: String
    var instructions: String
    var image: Image
    var reps: Int = 10
    var sets: Int = 4
}

class ExerciseModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var weeklyExercises: [String: [Exercise]] = [:] // map the days of the workout week to their exercises

    func setupPlan(for days: Int) {
        // reset the weeklyExercises for the given number of days
        let DaysOfWeek = ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7"]
        let selectedDays = DaysOfWeek.prefix(days)

        weeklyExercises = selectedDays.reduce(into: [:]) { dict, day in
            dict[day] = []
        }
    }
}
