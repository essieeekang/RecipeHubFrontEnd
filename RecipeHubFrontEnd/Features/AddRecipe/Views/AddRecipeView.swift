//
//  AddRecipeView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct AddRecipeView: View {
    @StateObject private var viewModel = AddRecipeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    let onRecipeCreated: ((Recipe) -> Void)?
    
    init(onRecipeCreated: ((Recipe) -> Void)? = nil) {
        self.onRecipeCreated = onRecipeCreated
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Recipe Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recipe Title")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            TextField("Enter recipe title", text: $viewModel.title)
                                .textFieldStyle(RoundedField())
                                .disabled(viewModel.isLoading)
                        }
                        
                        // Recipe Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            TextField("Describe your recipe", text: $viewModel.description, axis: .vertical)
                                .textFieldStyle(RoundedField())
                                .lineLimit(3...6)
                                .disabled(viewModel.isLoading)
                        }
                        
                        // Ingredients Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Ingredients")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                
                                Spacer()
                                
                                Button(action: viewModel.addIngredient) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.purple)
                                        .font(.title2)
                                }
                                .disabled(viewModel.isLoading)
                            }
                            
                            ForEach(Array(viewModel.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                                IngredientRowView(
                                    ingredient: $viewModel.ingredients[index],
                                    onRemove: {
                                        viewModel.removeIngredient(at: index)
                                    },
                                    isDisabled: viewModel.isLoading
                                )
                            }
                        }
                        
                        // Instructions Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Instructions")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                
                                Spacer()
                                
                                Button(action: viewModel.addInstruction) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.purple)
                                        .font(.title2)
                                }
                                .disabled(viewModel.isLoading)
                            }
                            
                            ForEach(Array(viewModel.instructions.enumerated()), id: \.offset) { index, instruction in
                                InstructionRowView(
                                    instruction: $viewModel.instructions[index],
                                    stepNumber: index + 1,
                                    onRemove: {
                                        viewModel.removeInstruction(at: index)
                                    },
                                    isDisabled: viewModel.isLoading
                                )
                            }
                        }
                        
                        // Recipe Settings
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Settings")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            VStack(spacing: 12) {
                                Toggle("Make recipe public", isOn: $viewModel.isPublic)
                                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                                    .disabled(viewModel.isLoading)
                                
                                Toggle("Mark as cooked", isOn: $viewModel.cooked)
                                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                                    .disabled(viewModel.isLoading)
                                
                                Toggle("Add to favorites", isOn: $viewModel.favourite)
                                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                                    .disabled(viewModel.isLoading)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Error Message
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Create Recipe Button
                        Button(action: createRecipe) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(viewModel.isLoading ? "Creating..." : "Create Recipe")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.canSubmit ? Color.purple : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!viewModel.canSubmit)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Create Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .alert("Recipe Created!", isPresented: $viewModel.isRecipeCreated) {
            Button("OK") {
                if let recipe = viewModel.createdRecipe {
                    onRecipeCreated?(recipe)
                }
                dismiss()
            }
        } message: {
            Text("Your recipe has been successfully created and saved.")
        }
    }
    
    private func createRecipe() {
        guard let currentUser = authViewModel.getCurrentUser() else {
            viewModel.errorMessage = "User not authenticated"
            return
        }
        
        viewModel.createRecipe(authorId: currentUser.id) { success in
            if success {
                print("Recipe created successfully")
            } else {
                print("Failed to create recipe")
            }
        }
    }
}

struct IngredientRowView: View {
    @Binding var ingredient: IngredientInput
    let onRemove: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Quantity
            TextField("Qty", value: $ingredient.quantity, format: .number)
                .textFieldStyle(RoundedField())
                .frame(width: 80)
                .disabled(isDisabled)
            
            // Unit
            TextField("Unit", text: $ingredient.unit)
                .textFieldStyle(RoundedField())
                .frame(width: 100)
                .disabled(isDisabled)
            
            // Name
            TextField("Ingredient name", text: $ingredient.name)
                .textFieldStyle(RoundedField())
                .disabled(isDisabled)
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
            .disabled(isDisabled)
        }
    }
}

struct InstructionRowView: View {
    @Binding var instruction: String
    let stepNumber: Int
    let onRemove: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Step number
            Text("\(stepNumber).")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
                .frame(width: 30, alignment: .leading)
            
            // Instruction text
            TextField("Enter instruction step", text: $instruction, axis: .vertical)
                .textFieldStyle(RoundedField())
                .lineLimit(2...4)
                .disabled(isDisabled)
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
            .disabled(isDisabled)
        }
    }
}

#Preview {
    AddRecipeView()
        .environmentObject(AuthViewModel())
}
