//
//  AddRecipeView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct AddRecipeView: View {
    @StateObject private var viewModel = AddRecipeViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
                        }
                        
                        // Recipe Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            TextField("Describe your recipe", text: $viewModel.description, axis: .vertical)
                                .textFieldStyle(RoundedField())
                                .lineLimit(3...6)
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
                            }
                            
                            ForEach(Array(viewModel.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                                IngredientRowView(
                                    ingredient: $viewModel.ingredients[index],
                                    onRemove: {
                                        viewModel.removeIngredient(at: index)
                                    }
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
                            }
                            
                            ForEach(Array(viewModel.instructions.enumerated()), id: \.offset) { index, instruction in
                                InstructionRowView(
                                    instruction: $viewModel.instructions[index],
                                    stepNumber: index + 1,
                                    onRemove: {
                                        viewModel.removeInstruction(at: index)
                                    }
                                )
                            }
                        }
                        
                        // Privacy Setting
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Privacy")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            HStack {
                                Toggle("Make recipe public", isOn: $viewModel.isPublic)
                                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                                
                                Spacer()
                                
                                Text(viewModel.isPublic ? "Public" : "Private")
                                    .font(.caption)
                                    .foregroundColor(.gray)
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
                        Button(action: viewModel.createRecipe) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Create Recipe")
                                        .font(.headline)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.canSubmit ? Color.purple : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!viewModel.canSubmit || viewModel.isLoading)
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
                }
            }
        }
        .alert("Recipe Created!", isPresented: $viewModel.isRecipeCreated) {
            Button("OK") {
                viewModel.resetForm()
                dismiss()
            }
        } message: {
            Text("Your recipe has been successfully created!")
        }
    }
}

struct IngredientRowView: View {
    @Binding var ingredient: AddRecipeViewModel.IngredientInput
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Quantity
            TextField("Qty", text: $ingredient.quantity)
                .textFieldStyle(RoundedField())
                .frame(width: 80)
                .keyboardType(.decimalPad)
            
            // Unit
            TextField("Unit", text: $ingredient.unit)
                .textFieldStyle(RoundedField())
                .frame(width: 100)
            
            // Name
            TextField("Ingredient name", text: $ingredient.name)
                .textFieldStyle(RoundedField())
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct InstructionRowView: View {
    @Binding var instruction: String
    let stepNumber: Int
    let onRemove: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Step number
            Text("\(stepNumber).")
                .font(.headline)
                .foregroundColor(.purple)
                .frame(width: 30, alignment: .leading)
            
            // Instruction text
            TextField("Enter instruction step", text: $instruction, axis: .vertical)
                .textFieldStyle(RoundedField())
                .lineLimit(2...4)
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    AddRecipeView()
}
