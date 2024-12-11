//
//  ContentView.swift
//  Multipage
///Users/troydeminico/Desktop/iosBackup/multiPage/Multipage2/Multipage2/MultiPage.swift
//  Created by Troy Deminico on 11/2/24.
//

import SwiftUI

struct ContentView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @ObservedObject var exerciseModel: ExerciseModel

    var body: some View {
        NavigationView {
            TabView {
                // Home Page Content
                ZStack {
                    // background Image no image in currently
                    Image("dumbbells")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea() // image will fill screen

                    VStack {
                        // header is centered
                        Text("Home Page")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 20)

                        VStack(spacing: 15) {
                            // temo text field
                            TextField("First Name", text: $firstName)
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .frame(maxWidth: 350)  // set max width for larger screens
                                .frame(height: 60)
                                .padding(.horizontal)
                            
                            // temp text field
                            TextField("Last Name", text: $lastName)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .frame(maxWidth: 350)
                                .frame(height: 60)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        Spacer() // pushes the content towards the center
                    }
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

                // ViewThree Tab
                ViewThree(exerciseModel: exerciseModel)
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Create")
                    }
                LogWorkoutView(exerciseModel: exerciseModel)
                    .tabItem(){
                        Image(systemName: "house.fill")
                        Text("Log")
                    }
            }
        }
    }
}

#Preview {
    ContentView(exerciseModel: ExerciseModel())
}
