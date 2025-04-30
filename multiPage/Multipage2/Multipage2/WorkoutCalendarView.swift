//
//  WorkoutCalendarView.swift
//  Multipage2
//
//  Created by Troy Deminico on 4/11/25.
//

import SwiftUI

struct WorkoutCalendarView: View {
    @State private var selectedDate = Date()
    @ObservedObject var exerciseModel: ExerciseModel
    let calendar = Calendar.current
    let currentDate = Date()

    var body: some View {
        VStack {
            // change months
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }

                Text(monthYearString(from: selectedDate))
                    .font(.title)
                    .bold()

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()

            // grid for cal
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(getMonthDays(), id: \.self) { date in
                    VStack {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(isWorkoutDay(date) ? .white : isCurrentDay(date) ? .blue : .black)
                            .frame(width: 35, height: 35)
                            .background(isCurrentDayAndWorkoutDay(date) ? Color.green : isWorkoutDay(date) ? Color.green : Color.clear)
                                .clipShape(Circle())
                                .overlay(
                                    isCurrentDay(date) ? Circle().stroke(Color.blue, lineWidth: 2) : nil
                                )
                            .onTapGesture { selectedDate = date }
                    }
                }
            }
            .padding()

            // Selected Day Workouts
            VStack {
                Text("Workouts for \(formattedDate(selectedDate))")
                    .font(.headline)

                let exercises = completedExercisesForSelectedDate
                if !exercises.isEmpty {
                    ForEach(exercises) { exercise in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                exercise.image
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())

                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                        .bold()
                                    Text("Completed on: \(exercise.dateCompleted?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }

                            if !exercise.setDetails.isEmpty {
                                ForEach(exercise.setDetails.indices, id: \.self) { index in
                                    let set = exercise.setDetails[index]
                                    Text("Set \(index + 1): \(set.reps) reps • \(set.weight) lbs")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            } else {
                                Text("No set details logged.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                } else {
                    Text("No workouts completed.")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
    }

    // MARK: - Helper Functions

    func getMonthDays() -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate) else { return [] }
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        return range.map { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
        }
    }

    func isWorkoutDay(_ date: Date) -> Bool {
        exerciseModel.completedDaysHistory.contains { entry in
            entry.1.contains { exercise in
                calendar.isDate(exercise.dateCompleted ?? Date.distantPast, inSameDayAs: date)
            }
        }
    }
    
    func isCurrentDayAndWorkoutDay(_ date: Date) -> Bool {
        return isCurrentDay(date) && isWorkoutDay(date)
    }

    func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    func isCurrentDay(_ date: Date) -> Bool {
        return calendar.isDate(date, inSameDayAs: currentDate)
    }

    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    func changeMonth(by value: Int) {
        selectedDate = calendar.date(byAdding: .month, value: value, to: selectedDate) ?? selectedDate
    }

    var completedExercisesForSelectedDate: [Exercise] {
        for (_, exercises) in exerciseModel.completedDaysHistory {
            if exercises.contains(where: { calendar.isDate($0.dateCompleted ?? Date.distantPast, inSameDayAs: selectedDate) }) {
                return exercises.filter {
                    calendar.isDate($0.dateCompleted ?? Date.distantPast, inSameDayAs: selectedDate)
                }
            }
        }
        return []
    }
}

// MARK: - Preview
struct WorkoutCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutCalendarView(exerciseModel: ExerciseModel())
    }
}


