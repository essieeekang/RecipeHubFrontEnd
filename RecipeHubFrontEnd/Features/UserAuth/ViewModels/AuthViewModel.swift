import Foundation

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private let userDefaultsKey = "currentUser"
    private let isLoggedInKey = "isLoggedIn"
    
    init() {
        loadUserFromStorage()
    }
    
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
                
        let request = LoginRequest(username: username, password: password)
        
        LoginAction(request: request).call { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let response = response {
                    self?.setCurrentUser(response.user)
                    self?.isLoggedIn = true
                } else {
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
                
        AddUserAction(
            parameters: AddUserRequest(
                username: username,
                email: email,
                password: password
            )
        ).call { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let response = response {
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
                    handler()
                } else {
                    self?.errorMessage = "Failed to create user. Please try again."
                }
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
        
        guard username != nil || email != nil || newPassword != nil else {
            errorMessage = "Please provide at least one field to update"
            completion(false)
            return
        }
        
        if newPassword != nil && (currentPassword?.isEmpty ?? true) {
            errorMessage = "Current password is required to change password"
            completion(false)
            return
        }
        
        if let newPassword = newPassword, newPassword.count < 6 || newPassword.count > 100 {
            errorMessage = "New password must be between 6 and 100 characters"
            completion(false)
            return
        }
        
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
                
        UpdateUserAction(userId: currentUser.id, parameters: request).call { [weak self] updatedUser in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let user = updatedUser {
                    self?.setCurrentUser(user)
                    completion(true)
                } else {
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
