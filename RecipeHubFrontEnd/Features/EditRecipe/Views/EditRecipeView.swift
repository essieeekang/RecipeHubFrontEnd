import SwiftUI

struct EditRecipeView: View {
    @StateObject private var viewModel: EditRecipeViewModel
    @Environment(\.dismiss) private var dismiss
    let onRecipeUpdated: ((Recipe) -> Void)?
    
    init(recipe: Recipe, authorId: Int, onRecipeUpdated: ((Recipe) -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: EditRecipeViewModel(recipe: recipe, authorId: authorId))
        self.onRecipeUpdated = onRecipeUpdated
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.purple)
                        TextField("Recipe title", text: $viewModel.title)
                            .textFieldStyle(RoundedField())
                            .disabled(viewModel.isLoading)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.purple)
                        TextField("Recipe description", text: $viewModel.description, axis: .vertical)
                            .textFieldStyle(RoundedField())
                            .lineLimit(3...6)
                            .disabled(viewModel.isLoading)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
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
                        
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                                IngredientRowView(
                                    ingredient: $viewModel.ingredients[index],
                                    onRemove: { viewModel.removeIngredient(at: index) },
                                    isDisabled: viewModel.isLoading
                                )
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
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
                        
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.instructions.enumerated()), id: \.offset) { index, instruction in
                                InstructionRowView(
                                    instruction: $viewModel.instructions[index],
                                    stepNumber: index + 1,
                                    onRemove: { viewModel.removeInstruction(at: index) },
                                    isDisabled: viewModel.isLoading
                                )
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Settings")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        VStack(spacing: 12) {
                            Toggle("Public Recipe", isOn: $viewModel.isPublic)
                                .disabled(viewModel.isLoading)
                            
                            Toggle("Mark as Cooked", isOn: $viewModel.cooked)
                                .disabled(viewModel.isLoading)
                            
                            Toggle("Add to Favorites", isOn: $viewModel.favourite)
                                .disabled(viewModel.isLoading)
                        }
                    }
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }

                    Button(action: updateRecipe) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Update Recipe")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canSubmit ? Color.purple : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.canSubmit)
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
    
    private func updateRecipe() {
        viewModel.updateRecipe { success in
            if success {
                let updatedRecipe = Recipe(
                    id: viewModel.originalRecipe.id,
                    title: viewModel.title,
                    description: viewModel.description,
                    ingredients: viewModel.ingredients.map { input in
                        Ingredient(
                            name: input.name,
                            unit: input.unit,
                            quantity: input.quantity
                        )
                    },
                    instructions: viewModel.instructions,
                    imageUrl: viewModel.originalRecipe.imageUrl,
                    isPublic: viewModel.isPublic,
                    cooked: viewModel.cooked,
                    favourite: viewModel.favourite,
                    likeCount: viewModel.originalRecipe.likeCount,
                    authorId: viewModel.authorId,
                    authorUsername: viewModel.originalRecipe.authorUsername,
                    originalRecipeId: viewModel.originalRecipe.originalRecipeId,
                    tags: viewModel.originalRecipe.tags,
                    createdAt: viewModel.originalRecipe.createdAt,
                    updatedAt: Date()
                )
                
                onRecipeUpdated?(updatedRecipe)
                dismiss()
            }
        }
    }
}

 
