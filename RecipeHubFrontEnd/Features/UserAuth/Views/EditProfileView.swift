//
//  EditProfileView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var isProfileUpdated = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.purple)
                            
                            Text("Edit Profile")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                            
                            Text("Update your account information")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            TextField("Enter new username", text: $username)
                                .textFieldStyle(RoundedField())
                                .disabled(isLoading)
                                .textInputAutocapitalization(.never)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            TextField("Enter new email", text: $email)
                                .textFieldStyle(RoundedField())
                                .disabled(isLoading)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Change Password")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            VStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Current Password")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    SecureField("Enter current password", text: $currentPassword)
                                        .textFieldStyle(RoundedField())
                                        .disabled(isLoading)
                                        .textInputAutocapitalization(.never)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("New Password")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    SecureField("Enter new password", text: $newPassword)
                                        .textFieldStyle(RoundedField())
                                        .disabled(isLoading)
                                        .textInputAutocapitalization(.never)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Confirm New Password")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    SecureField("Confirm new password", text: $confirmPassword)
                                        .textFieldStyle(RoundedField())
                                        .disabled(isLoading)
                                        .textInputAutocapitalization(.never)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Button(action: updateProfile) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(isLoading ? "Updating..." : "Update Profile")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSubmit ? Color.purple : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!canSubmit)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
            }
        }
        .alert("Profile Updated", isPresented: $isProfileUpdated) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your profile has been successfully updated.")
        }
        .onAppear {
            loadCurrentUserData()
        }
    }
    
    private var canSubmit: Bool {
        let hasChanges = !username.isEmpty || !email.isEmpty || !newPassword.isEmpty
        
        let passwordValid = newPassword.isEmpty ||
            (!currentPassword.isEmpty && newPassword == confirmPassword && newPassword.count >= 6)
        
        return hasChanges && passwordValid && !isLoading
    }
    
    private func loadCurrentUserData() {
        if let currentUser = authViewModel.getCurrentUser() {
            username = currentUser.username
            email = currentUser.email
        }
    }
    
    private func updateProfile() {
        guard canSubmit else {
            errorMessage = "Please fill in at least one field to update"
            return
        }
        
        // Validate password confirmation
        if !newPassword.isEmpty && newPassword != confirmPassword {
            errorMessage = "New passwords do not match"
            return
        }
        
        // Validate password length
        if !newPassword.isEmpty && newPassword.count < 6 {
            errorMessage = "New password must be at least 6 characters"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        let updateUsername = username.isEmpty ? nil : username
        let updateEmail = email.isEmpty ? nil : email
        let updateCurrentPassword = currentPassword.isEmpty ? nil : currentPassword
        let updateNewPassword = newPassword.isEmpty ? nil : newPassword
        
        authViewModel.updateUser(
            username: updateUsername,
            email: updateEmail,
            currentPassword: updateCurrentPassword,
            newPassword: updateNewPassword
        ) { success in
            isLoading = false
            
            if success {
                isProfileUpdated = true
                currentPassword = ""
                newPassword = ""
                confirmPassword = ""
            } else {
                errorMessage = authViewModel.errorMessage
            }
        }
    }
}
