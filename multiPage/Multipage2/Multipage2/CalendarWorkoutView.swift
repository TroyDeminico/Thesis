import SwiftUI

struct WorkoutCalendarView: View {
    @State private var selectedDate = Date()
    @ObservedObject var exerciseModel: ExerciseModel
    let calendar = Calendar.current

    var body: some View {
        VStack {
            // Header with Month & Navigation
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

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                
                // Days of the Month
                ForEach(getMonthDays(), id: \.self) { date in
                    VStack {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(isWorkoutDay(date) ? .white : .black)
                            .frame(width: 35, height: 35)
                            .background(isWorkoutDay(date) ? Color.blue : Color.clear)
                            .clipShape(Circle())
                            .onTapGesture { selectedDate = date }
                    }
                }
            }
            .padding()

            // Selected Day Workouts
            VStack {
                Text("Workouts for \(formattedDate(selectedDate))")
                    .font(.headline)
                
                if let exercises = exerciseModel.weeklyExercises[dayOfWeek(from: selectedDate)], !exercises.isEmpty {
                    ForEach(exercises) { exercise in
                        HStack {
                            exercise.image
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .bold()
                                Text("\(exercise.sets) sets of \(exercise.reps) reps")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("No workouts planned.")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding()
        }
    }

    // MARK: - Helper Functions

    // Get the start of the month and its days
    func getMonthDays() -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate) else {
            return []
        }
        
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!

        // Convert ClosedRange to Range properly
        let days = range.lowerBound..<range.upperBound

        return days.map { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
        }
    }



    // Check if a date has workouts
    func isWorkoutDay(_ date: Date) -> Bool {
        return exerciseModel.weeklyExercises.keys.contains(dayOfWeek(from: date))
    }

    // Get the weekday name (e.g., "Monday") from a date
    func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    // Format month and year
    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    // Format full date
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    // Navigate months
    func changeMonth(by value: Int) {
        selectedDate = calendar.date(byAdding: .month, value: value, to: selectedDate) ?? selectedDate
    }
}

#Preview {
    WorkoutCalendarView(exerciseModel: ExerciseModel())
}
