//
//  CreateBookView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct CreateBookView: View {
    @ObservedObject var viewModel: RecipeBooksViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var isPublic = true
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var canSubmit: Bool {
        !name.isEmpty && !description.isEmpty && !isLoading
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Book Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Book Name")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            TextField("Enter book name", text: $name)
                                .textFieldStyle(RoundedField())
                                .disabled(isLoading)
                        }
                        
                        // Book Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            TextField("Describe your recipe book", text: $description, axis: .vertical)
                                .textFieldStyle(RoundedField())
                                .lineLimit(3...6)
                                .disabled(isLoading)
                        }
                        
                        // Privacy Setting
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Privacy")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            HStack {
                                Toggle("Make book public", isOn: $isPublic)
                                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                                    .disabled(isLoading)
                                
                                Spacer()
                                
                                Text(isPublic ? "Public" : "Private")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Error Message
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Create Book Button
                        Button(action: createBook) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(isLoading ? "Creating..." : "Create Book")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSubmit ? Color.purple : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!canSubmit)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Create Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                    .disabled(isLoading)
                }
            }
        }
    }
    
    private func createBook() {
        guard canSubmit else {
            errorMessage = "Please fill in all required fields"
            return
        }
        
        guard let currentUser = authViewModel.getCurrentUser() else {
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        viewModel.createBook(
            name: name,
            description: description,
            isPublic: isPublic,
            authorId: currentUser.id,
            authorUsername: currentUser.username
        ) { success in
            DispatchQueue.main.async {
                isLoading = false
                
                if success {
                    print("CreateBookView: Book created successfully, dismissing in 0.5 seconds")
                    // Add a small delay to ensure the UI updates are processed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                } else {
                    errorMessage = "Failed to create recipe book. Please try again."
                }
            }
        }
    }
}

#Preview {
    CreateBookView(viewModel: RecipeBooksViewModel())
} 