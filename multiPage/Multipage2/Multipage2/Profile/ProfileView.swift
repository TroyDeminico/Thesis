//
//  ProfileView.swift
//  Multipage2
//
//  Created by Troy Deminico on 2/13/25.
//
// followed a tutorial to help with this

import SwiftUI


struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var navigateToWorkoutPlan = false
    var body: some View {
        if let user = viewModel.currentUser{
            List {
                Section {
                    HStack{
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4){
                            // displays the users info
                            Text(user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("General") {
                    HStack {
                        SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                        Spacer()
                        Text("1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                // lets the user view their plan 
                Section("View Plan") {
                    NavigationLink(
                        destination: LogWorkoutView(exerciseModel: ExerciseModel())
                            .environmentObject(viewModel)
                    ) {
                        SettingsRowView(imageName: "arrow.left.circle.fill", title: "View Plan", tintColor: .green)
                    }
                }
                

                
                Section("Account"){
                    Button{
                        viewModel.signOut()
                    }label:{
                        SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                    }
                    
                    Button{
                        print("Sign Out")
                    }label:{
                        SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                    }
                    
                }
            }
        } else {
            // incase in app without being signed in
            VStack {
                Spacer()
                Text("No user logged in")
                    .foregroundColor(.gray)
                    .font(.headline)
                Spacer()
                Section("Account"){
                    Button{
                        viewModel.signOut()
                    }label:{
                        SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
