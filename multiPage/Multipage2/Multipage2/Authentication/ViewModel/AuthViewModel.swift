//
//  AuthViewModel.swift
//  Multipage2
//
//  Created by Troy Deminico on 3/22/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationFormProtocol {
    var formsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    
    var exerciseModel: ExerciseModel?
    
    init(exerciseModel: ExerciseModel? = nil) {
            self.exerciseModel = exerciseModel
            setupAuthListener()
        }
    
    func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            Task {
                if let user = user {
                    self.userSession = user
                    self.isAuthenticated = true
                    await self.fetchUser()
                    await self.exerciseModel?.fetchWorkoutPlanFromFirebase()
                } else {
                    self.userSession = nil
                    self.currentUser = nil
                    self.isAuthenticated = false
                }
            }
        }
    }

    
    func signIn(withEmail email: String, password: String) async throws{
        do {
            // signs in the user and makes app have info
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            self.isAuthenticated = true
            await fetchUser()
            await exerciseModel?.fetchWorkoutPlanFromFirebase()
            print("signed in...")
        } catch {
            print("failed to log in \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            self.isAuthenticated = true

            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)

            // Create a default empty weekly plan
            let defaultWeeklyPlan: [String: [[String: Any]]] = [
                "Day 1": [],
                "Day 2": [],
                "Day 3": [],
                "Day 4": [],
                "Day 5": [],
                "Day 6": [],
                "Day 7": []
            ]

            // Combine user info + default workout plan into one write
            var userData: [String: Any] = [
                "userInfo": encodedUser,
                "weeklyExercises": defaultWeeklyPlan
            ]

            try await Firestore.firestore().collection("users").document(user.id).setData(userData)

            await fetchUser()

            print("Created user.")
        } catch {
            print("Failed with error: \(error.localizedDescription)")
        }

        print("create user...")
    }

    
    func signOut(){
        do {
            try Auth.auth().signOut() // signs out on backend
            self.userSession = nil
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            print("failed to sign out \(error.localizedDescription)")
        }
    }
    
    func deleteAccount(){
        
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument()

        if let data = snapshot?.data(),
           let userInfo = data["userInfo"] as? [String: Any] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: userInfo)
                self.currentUser = try JSONDecoder().decode(User.self, from: jsonData)
                print("current user is \(String(describing: currentUser))")
            } catch {
                print("Failed to decode user: \(error.localizedDescription)")
            }
        } else {
            print("No userInfo found in Firestore document")
        }
    }

}
