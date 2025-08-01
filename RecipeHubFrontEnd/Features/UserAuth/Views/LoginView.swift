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

//struct LoginView: View {
//    @ObservedObject var viewModel: LoginViewModel = LoginViewModel()
//    var body: some View {
//        VStack {
//            Spacer()
//            VStack {
//                TextField(
//                    "enter username here",
//                    text: $viewModel.username
//                )
//                .disableAutocorrection(true)
//                .padding(.top, 20)
//                .textInputAutocapitalization(.never)
//
//                Divider()
//
//                SecureField(
//                    "enter password here",
//                    text: $viewModel.password
//                )
//                .textInputAutocapitalization(.never)
//                .padding(.top, 20)
//                Divider()
//            }
//
//            Spacer()
//
//            Button(
//                action: viewModel.login,
//                label: {
//                    Text("Log In")
//                        .font(.system(size: 24, weight: .bold, design: .default))
//                        .frame(maxWidth: .infinity, maxHeight: 60)
//                        .foregroundColor(Color.white)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//            )
//        }
//        .padding(30)
//    }
//}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(onBack: {})
            .environmentObject(AuthViewModel())
    }
}
