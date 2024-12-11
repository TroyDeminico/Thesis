//
//  ApiHandler.swift
//  Multipage
//
//  Created by Troy Deminico on 11/11/24.
//

// ApiHandler.swift
import Foundation
struct ExerciseData: Identifiable {
    var id = UUID()
    var name: String
    var instructions: String
}

class ApiHandler {
    func fetchExercises(for muscle: String, completion: @escaping ([ExerciseData]) -> Void) {
        guard let muscleEncoded = muscle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.api-ninjas.com/v1/exercises?muscle=\(muscleEncoded)") else {
            print("Invalid URL or muscle encoding.")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("mx39hmHv6zcqQZVL+V/ffA==P6Ii9WOgs8MIFiV5", forHTTPHeaderField: "X-Api-Key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch data: \(error?.localizedDescription ?? "No data")")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    let exercises = json.compactMap { item -> ExerciseData? in
                        guard let name = item["name"] as? String,
                              let instructions = item["instructions"] as? String else { return nil }
                        return ExerciseData(name: name, instructions: instructions)
                    }
                    DispatchQueue.main.async {
                        completion(exercises)
                    }
                }
            } catch {
                print("JSON decoding failed: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}

