//
//  AuthViewModel.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false {
        didSet {
            print("AuthViewModel: isLoggedIn changed from \(oldValue) to \(isLoggedIn)")
        }
    }
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""

    func login(completion handler: @escaping () -> Void) {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Username and password cannot be empty"
            return
        }
        
        print("Attempting login with username: \(username)")
        
        LoginAction(
            parameters: LoginRequest(
                username: username,
                password: password
            )
        ).call { response in
            print("LoginAction completion called with response: \(response)")
            DispatchQueue.main.async {
                print("Login successful! Welcome: \(response.body)")
                print("Setting isLoggedIn to true")
                self.isLoggedIn = true
                print("isLoggedIn is now: \(self.isLoggedIn)")
                self.errorMessage = ""
                print("Calling login completion handler")
                handler()
            }
        }
    }

    func addUser(completion handler: @escaping () -> Void) {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required"
            return
        }
        
        print("Attempting to create user with username: \(username), email: \(email)")
        
        AddUserAction(
            parameters: AddUserRequest(
                username: username,
                email: email,
                password: password
            )
        ).call { response in
            print("AddUserAction completion called with response: \(response)")
            DispatchQueue.main.async {
                print("User creation successful! Welcome: \(response.username)")
                print("Setting isLoggedIn to true")
                self.isLoggedIn = true
                self.errorMessage = ""
                print("Calling addUser completion handler")
                handler()
            }
        }
    }

    func logout() {
        isLoggedIn = false
        username = ""
        email = ""
        password = ""
    }
}
