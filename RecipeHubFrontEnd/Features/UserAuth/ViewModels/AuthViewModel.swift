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
    
    func updateUser(username: String?, email: String?, currentPassword: String?, newPassword: String?, completion: @escaping (Bool) -> Void) {
        guard let currentUser = currentUser else {
            errorMessage = "User not authenticated"
            completion(false)
            return
        }
        
        // Validate that at least one field is being updated
        guard username != nil || email != nil || newPassword != nil else {
            errorMessage = "Please provide at least one field to update"
            completion(false)
            return
        }
        
        // Validate that current password is provided if changing password
        if newPassword != nil && (currentPassword?.isEmpty ?? true) {
            errorMessage = "Current password is required to change password"
            completion(false)
            return
        }
        
        // Validate new password length if provided
        if let newPassword = newPassword, newPassword.count < 6 || newPassword.count > 100 {
            errorMessage = "New password must be between 6 and 100 characters"
            completion(false)
            return
        }
        
        // Validate email format if provided
        if let email = email, !isValidEmail(email) {
            errorMessage = "Please enter a valid email address"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        let request = UpdateUserRequest(
            currentPassword: currentPassword,
            username: username,
            email: email,
            newPassword: newPassword
        )
        
        print("Updating user with ID: \(currentUser.id)")
        
        UpdateUserAction(userId: currentUser.id, parameters: request).call { [weak self] updatedUser in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let user = updatedUser {
                    print("Successfully updated user: \(user.username)")
                    self?.setCurrentUser(user)
                    completion(true)
                } else {
                    print("Failed to update user")
                    self?.errorMessage = "Failed to update profile. Please try again."
                    completion(false)
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
