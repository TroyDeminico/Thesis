import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// individual sets
struct ExerciseSet: Codable, Identifiable {
    let id = UUID()
    var reps: Int
    var weight: Int
}

// actual exercise
struct Exercise: Identifiable {
    var id = UUID()
    var name: String
    var instructions: String
    var imageName: String 
    var reps: Int = 10 // default reps
    var sets: Int = 4 // default sets
    var weight: Int = 10 // default weight
    var setDetails: [ExerciseSet] = [] // sets
    var dateCompleted: Date?
    var day: String = ""

    var image: Image {
        Image(systemName: imageName)
    }
}

class ExerciseModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var weeklyExercises: [String: [Exercise]] = [:]
    @Published var recentWorkouts: [Exercise] = []
    @Published var completedDays: [String] = []
    @Published var completedDaysHistory: [(String, [Exercise])] = []
    @Published var planDays: Int = 3


    func setupPlan(for days: Int) {
        let DaysOfWeek = ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7"]
        let selectedDays = DaysOfWeek.prefix(days)

        weeklyExercises = selectedDays.reduce(into: [:]) { dict, day in
            dict[day] = []
        }
    }

    func addRecentWorkout(_ exercise: Exercise) {
        if recentWorkouts.count >= 5 {
            recentWorkouts.removeFirst()
        }
        recentWorkouts.append(exercise)
    }

    // saves the plan to the users info on firebase
    func saveWorkoutPlanToFirebase() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        let planData = weeklyExercises.mapValues { exercises in
            exercises.map { exercise in
                return [
                    "id": exercise.id.uuidString,
                    "name": exercise.name,
                    "instructions": exercise.instructions,
                    "imageName": exercise.imageName,
                    "reps": exercise.reps,
                    "sets": exercise.sets,
                    "weight": exercise.weight,
                    "setDetails": exercise.setDetails.map { ["reps": $0.reps, "weight": $0.weight] },
                    "dateCompleted": exercise.dateCompleted?.timeIntervalSince1970 ?? 0,
                    "day": exercise.day
                ]
            }
        }
        // completed workouts saved here
        let completedData = completedDaysHistory.map { (day, exercises) in
            return [
                "day": day,
                "exercises": exercises.map { exercise in
                    return [
                        "id": exercise.id.uuidString,
                        "name": exercise.name,
                        "instructions": exercise.instructions,
                        "imageName": exercise.imageName,
                        "reps": exercise.reps,
                        "sets": exercise.sets,
                        "weight": exercise.weight,
                        "setDetails": exercise.setDetails.map { ["reps": $0.reps, "weight": $0.weight] },
                        "dateCompleted": exercise.dateCompleted?.timeIntervalSince1970 ?? 0,
                        "day": exercise.day
                    ]
                }
            ]
        }

        do {
            try await db.collection("users").document(uid).setData([
                "weeklyExercises": planData,
                "completedDaysHistory": completedData
            ], merge: true)

            print("Workout plan saved.")
        } catch {
            print("Error saving plan: \(error.localizedDescription)")
        }
    }


    // gets the users plan to be displayed etc.
    func fetchWorkoutPlanFromFirebase() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            
            if let data = snapshot.data()?["weeklyExercises"] as? [String: [[String: Any]]] {
                var loadedPlan: [String: [Exercise]] = [:]
                
                for (day, exercisesArray) in data {
                    let exercises: [Exercise] = exercisesArray.compactMap { dict in
                        guard
                            let name = dict["name"] as? String,
                            let instructions = dict["instructions"] as? String,
                            let imageName = dict["imageName"] as? String,
                            let reps = dict["reps"] as? Int,
                            let sets = dict["sets"] as? Int,
                            let weight = dict["weight"] as? Int,
                            let dateRaw = dict["dateCompleted"] as? TimeInterval,
                            let day = dict["day"] as? String
                        else { return nil }
                        
                        // info for set of exercise
                        let setDetails: [ExerciseSet] = (dict["setDetails"] as? [[String: Int]])?.compactMap { setDict in
                            guard
                                let reps = setDict["reps"],
                                let weight = setDict["weight"]
                            else { return nil }
                            
                            return ExerciseSet(reps: reps, weight: weight)
                        } ?? []
                        
                        // everything needed for specific ecercise
                        return Exercise(
                            name: name,
                            instructions: instructions,
                            imageName: imageName,
                            reps: reps,
                            sets: sets,
                            weight: weight,
                            setDetails: setDetails,
                            dateCompleted: Date(timeIntervalSince1970: dateRaw),
                            day: day
                        )
                    }
                    
                    loadedPlan[day] = exercises
                }
                
                DispatchQueue.main.async {
                    self.weeklyExercises = loadedPlan
                }
            }
            
            // same for completed now
            if let completedData = snapshot.data()?["completedDaysHistory"] as? [[String: Any]] {
                var loadedHistory: [(String, [Exercise])] = []
                
                for entry in completedData {
                    if let day = entry["day"] as? String,
                       let exercisesArray = entry["exercises"] as? [[String: Any]] {
                        
                        let exercises = exercisesArray.compactMap { dict -> Exercise? in
                            guard
                                let name = dict["name"] as? String,
                                let instructions = dict["instructions"] as? String,
                                let imageName = dict["imageName"] as? String,
                                let reps = dict["reps"] as? Int,
                                let sets = dict["sets"] as? Int,
                                let weight = dict["weight"] as? Int,
                                let dateRaw = dict["dateCompleted"] as? TimeInterval,
                                let day = dict["day"] as? String
                            else { return nil }
                            
                            let setDetails: [ExerciseSet] = (dict["setDetails"] as? [[String: Int]])?.compactMap { setDict in
                                guard
                                    let reps = setDict["reps"],
                                    let weight = setDict["weight"]
                                else { return nil }
                                
                                return ExerciseSet(reps: reps, weight: weight)
                            } ?? []
                            
                            return Exercise(
                                name: name,
                                instructions: instructions,
                                imageName: imageName,
                                reps: reps,
                                sets: sets,
                                weight: weight,
                                setDetails: setDetails,
                                dateCompleted: Date(timeIntervalSince1970: dateRaw),
                                day: day
                            )
                        }
                        
                        loadedHistory.append((day, exercises))
                    }
                }
                
                DispatchQueue.main.async {
                    self.completedDaysHistory = loadedHistory
                }
            }
            
        } catch {
            print("Failed to fetch workouts: \(error.localizedDescription)")
        }
    }
}
