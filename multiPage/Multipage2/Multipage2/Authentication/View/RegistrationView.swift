//
//  RegistrationView.swift
//  Multipage2
//
//  Created by Troy Deminico on 2/13/25.
//
// followed a tutorial to help with this 

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmpassword = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack{
            // image
            Image("loginIcon")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 20)
                .padding(.vertical, 32)
            
            VStack(spacing: 24){
                // where user enters their info
                InputView(text: $email,
                          title: "Email Address",
                          placeholder: "Name@Example.com")
                    .autocapitalization(.none)
                
                InputView(text: $fullname,
                          title: "Full name",
                          placeholder: "Enter Your Name")
                    .autocapitalization(.none)
                
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter Password here",
                          isSecureField: true)
                
                ZStack(alignment: .trailing){
                    InputView(text: $confirmpassword,
                              title: "Confirm Password",
                              placeholder: "Confirm Password here",
                              isSecureField: true)
                    
                    // check for password
                    if !confirmpassword.isEmpty && !password.isEmpty && password.count > 5 {
                        if password == confirmpassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                        }else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Button{
                Task{
                    try await viewModel.createUser(withEmail: email, password: password, fullname: fullname)
                }
            } label: {
                HStack{
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemBlue))
            .disabled(!formsValid)
            .opacity(formsValid ? 1.0 : 0.5)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Spacer()
            
            Button{
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Text("Already have an account?")
                    Text("Sign in")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
            }
                   
        }
    }
}

extension RegistrationView: AuthenticationFormProtocol {
    var formsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmpassword == password
        && !fullname.isEmpty
    }

    #Preview {
        RegistrationView()
            .environmentObject(AuthViewModel())
    }
}
