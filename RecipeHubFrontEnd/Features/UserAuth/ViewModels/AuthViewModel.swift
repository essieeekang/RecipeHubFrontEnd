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
    @Published var currentUser: User?
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    
    // UserDefaults keys
    private let userDefaultsKey = "currentUser"
    private let isLoggedInKey = "isLoggedIn"
    
    init() {
        loadUserFromStorage()
    }
    
    // MARK: - User Management
    
    func setCurrentUser(_ user: User) {
        currentUser = user
        saveUserToStorage(user)
    }
    
    func getCurrentUserId() -> Int? {
        return currentUser?.id
    }
    
    func getCurrentUsername() -> String? {
        return currentUser?.username
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    // MARK: - Storage Management
    
    private func saveUserToStorage(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            UserDefaults.standard.set(true, forKey: isLoggedInKey)
        }
    }
    
    private func loadUserFromStorage() {
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isLoggedIn = UserDefaults.standard.bool(forKey: isLoggedInKey)
        }
    }
    
    private func clearUserFromStorage() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.set(false, forKey: isLoggedInKey)
    }

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
                print("Login successful! Welcome: \(response.username)")
                print("Setting isLoggedIn to true")
                
                // Create a user object from login response
                let user = User(
                    id: response.userId,
                    username: response.username,
                    email: response.email,
                    createdAt: ISO8601DateFormatter().string(from: Date()),
                    updatedAt: ISO8601DateFormatter().string(from: Date())
                )
                
                self.setCurrentUser(user)
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
                
                // Create user object from registration response
                let user = User(
                    id: response.id,
                    username: response.username,
                    email: response.email,
                    createdAt: response.createdAt,
                    updatedAt: ISO8601DateFormatter().string(from: Date())
                )
                
                self.setCurrentUser(user)
                self.isLoggedIn = true
                self.errorMessage = ""
                print("Calling addUser completion handler")
                handler()
            }
        }
    }

    func logout() {
        isLoggedIn = false
        currentUser = nil
        username = ""
        email = ""
        password = ""
        clearUserFromStorage()
    }
}
