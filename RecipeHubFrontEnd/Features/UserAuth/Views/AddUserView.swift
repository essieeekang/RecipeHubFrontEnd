//
//  AddUserView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct AddUserView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack{
            Color(red: 1.0, green: 0.95, blue: 0.97).ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Join RecipeHub")
                    .font(.title)
                    .fontWeight(.bold)
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedField())
                    .onChange(of: username) { _, newValue in
                        authViewModel.username = newValue
                    }
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedField())
                    .onChange(of: email) { _, newValue in
                        authViewModel.email = newValue
                    }
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedField())
                    .onChange(of: password) { _, newValue in
                        authViewModel.password = newValue
                    }
                
                Button("Create Account") {
                    authViewModel.addUser {
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

struct AddUserScreen_Previews: PreviewProvider {
    static var previews: some View {
        AddUserView()
            .environmentObject(AuthViewModel())
    }
}
