//
//  AuthViewModel.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""

    func login(completion handler: @escaping () -> Void) {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Username and password cannot be empty"
            return
        }
        LoginAction(
            parameters: LoginRequest(
                username: username,
                password: password
            )
        ).call { response in
            print("Welcome! Your new username is: ", response.body)
            self.isLoggedIn = true
            self.errorMessage = ""
            handler()
        }
    }

    func addUser(completion handler: @escaping () -> Void) {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required"
            return
        }
        AddUserAction(
            parameters: AddUserRequest(
                username: username,
                email: email,
                password: password
            )
        ).call { response in
            print("Welcome! Your new username is: ", response.username)
            self.isLoggedIn = true
            self.errorMessage = ""
            handler()
        }
    }

    func logout() {
        isLoggedIn = false
        username = ""
        email = ""
        password = ""
    }
}
