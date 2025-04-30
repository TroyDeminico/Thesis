//
//  LoginView.swift
//  Multipage2
//
//  Created by Troy Deminico on 2/5/25.
//
// followed a tutorial to help with this 

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        NavigationStack{
            VStack{
                // image
                Image("loginIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 20)
                    .padding(.vertical, 32)
                
                
                
                //forms
                VStack(spacing: 24){
                    InputView(text: $email, title: "Email Address", placeholder: "Name@Example.com")
                        .autocapitalization(.none)
                    
                    InputView(text: $password, title: "Password", placeholder: "Enter Password here", isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // sign in btn
                
                Button{
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    HStack{
                        Text("SIGN IN")
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
                
                // sign up btn
                
                NavigationLink{
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
                
            }
        }
    }
}

extension LoginView: AuthenticationFormProtocol {
    var formsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
    
    
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
