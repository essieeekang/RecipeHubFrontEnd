//
//  EditBookView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct EditBookView: View {
    let book: RecipeBook
    @ObservedObject var viewModel: RecipeBooksViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var isPublic: Bool
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    init(book: RecipeBook, viewModel: RecipeBooksViewModel) {
        self.book = book
        self.viewModel = viewModel
        self._name = State(initialValue: book.name)
        self._description = State(initialValue: book.description)
        self._isPublic = State(initialValue: book.isPublic)
    }
    
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
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Privacy")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            VStack(spacing: 12) {
                                Toggle("Make book public", isOn: $isPublic)
                                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                                    .disabled(isLoading)
                                
                                Text(isPublic ? "Anyone can see and use this book" : "Only you can see this book")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Current Recipe Count
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recipes in Book")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.purple)
                                Text("\(book.recipeIds.count) recipe\(book.recipeIds.count == 1 ? "" : "s")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
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
                        
                        // Update Button
                        Button(action: updateBook) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(isLoading ? "Updating..." : "Update Book")
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
            .navigationTitle("Edit Book")
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
    
    private func updateBook() {
        isLoading = true
        errorMessage = ""
        
        viewModel.editRecipeBook(
            bookId: book.id,
            name: name,
            description: description,
            isPublic: isPublic,
            recipeIds: book.recipeIds, // Keep existing recipes
            completion: { success in
                if success {
                    dismiss()
                } else {
                    errorMessage = viewModel.errorMessage
                }
            }
        )
    }
} 