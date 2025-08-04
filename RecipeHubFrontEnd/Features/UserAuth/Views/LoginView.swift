//
//  LoginView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let onBack: () -> Void
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        ZStack{
            Color(red: 1.0, green: 0.95, blue: 0.97).ignoresSafeArea()
            VStack(spacing: 24) {
                HStack {
                    Button("Back") {
                        onBack()
                    }
                    .foregroundColor(.gray)
                    Spacer()
                }
                
                Text("Welcome Back")
                    .font(.title)
                    .fontWeight(.bold)
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedField())
                    .onChange(of: username) { _, newValue in
                        authViewModel.username = newValue
                    }
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedField())
                    .onChange(of: password) { _, newValue in
                        authViewModel.password = newValue
                    }
                
                Button("Log In") {
                    print("Login button tapped")
                    print("Username: \(authViewModel.username)")
                    print("Password: \(authViewModel.password)")
                    authViewModel.login {
                        print("Login completion handler called")
                        // Navigation is handled automatically by RootView
                        // when isLoggedIn becomes true
                    }
                }
                .buttonStyle(FilledButtonStyle())
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(onBack: {})
            .environmentObject(AuthViewModel())
    }
}
