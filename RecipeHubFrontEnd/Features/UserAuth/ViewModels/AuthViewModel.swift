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
    @Published var isLoading: Bool = false
    
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

    func login() {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter both username and password"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        print("Attempting login with username: \(username)")
        
        let request = LoginRequest(username: username, password: password)
        
        LoginAction(request: request).call { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let response = response {
                    print("Login successful! Welcome: \(response.message)")
                    print("User ID: \(response.user.id), Username: \(response.user.username)")
                    
                    // Set the current user from the response
                    self?.setCurrentUser(response.user)
                    self?.isLoggedIn = true
                    print("isLoggedIn is now: \(self?.isLoggedIn ?? false)")
                } else {
                    print("Login failed")
                    self?.errorMessage = "Login failed. Please check your credentials."
                }
            }
        }
    }

    func addUser(completion handler: @escaping () -> Void) {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        print("Attempting to create user with username: \(username), email: \(email)")
        
        AddUserAction(
            parameters: AddUserRequest(
                username: username,
                email: email,
                password: password
            )
        ).call { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                print("AddUserAction completion called with response: \(response)")
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
                
                self?.setCurrentUser(user)
                self?.isLoggedIn = true
                self?.errorMessage = ""
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
