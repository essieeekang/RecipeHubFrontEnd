import Foundation
import SwiftUI

class EditRecipeViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var ingredients: [IngredientInput] = []
    @Published var instructions: [String] = []
    @Published var isPublic: Bool = true
    @Published var cooked: Bool = false
    @Published var favourite: Bool = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    // Tag management
    @Published var currentTags: [String] = []
    @Published var newTag: String = ""
    @Published var tagsToAdd: [String] = []
    @Published var tagsToDelete: [String] = []
    
    let originalRecipe: Recipe
    let authorId: Int
    
    init(recipe: Recipe, authorId: Int) {
        self.originalRecipe = recipe
        self.authorId = authorId
        
        // Populate form with existing recipe data
        self.title = recipe.title
        self.description = recipe.description
        self.ingredients = recipe.ingredients.map { ingredient in
            IngredientInput(name: ingredient.name, unit: ingredient.unit, quantity: ingredient.quantity)
        }
        self.instructions = recipe.instructions
        self.isPublic = recipe.isPublic
        self.cooked = recipe.cooked
        self.favourite = recipe.favourite
        self.currentTags = recipe.tags ?? []
    }
    
    var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !ingredients.isEmpty &&
        !instructions.isEmpty &&
        !isLoading
    }
    
    // MARK: - Ingredients Management
    
    func addIngredient() {
        ingredients.append(IngredientInput())
    }
    
    func removeIngredient(at index: Int) {
        ingredients.remove(at: index)
    }
    
    // MARK: - Instructions Management
    
    func addInstruction() {
        instructions.append("")
    }
    
    func removeInstruction(at index: Int) {
        instructions.remove(at: index)
    }
    
    // MARK: - Tag Management
    
    func addNewTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !currentTags.contains(trimmedTag) && !tagsToAdd.contains(trimmedTag) {
            tagsToAdd.append(trimmedTag)
            newTag = ""
        }
    }
    
    func removeTagToAdd(at index: Int) {
        tagsToAdd.remove(at: index)
    }
    
    func deleteTag(_ tag: String) {
        if currentTags.contains(tag) && !tagsToDelete.contains(tag) {
            tagsToDelete.append(tag)
        }
    }
    
    func undoTagDeletion(_ tag: String) {
        tagsToDelete.removeAll { $0 == tag }
    }
    
    // MARK: - Recipe Update
    
    func updateRecipe(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
        
        // Prepare the request
        let request = UpdateRecipeRequest(
            authorId: authorId,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients.map { input in
                Ingredient(
                    name: input.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    unit: input.unit.trimmingCharacters(in: .whitespacesAndNewlines),
                    quantity: input.quantity
                )
            },
            instructions: instructions.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty },
            imageUrl: originalRecipe.imageUrl,
            isPublic: isPublic,
            cooked: cooked,
            favourite: favourite,
            likeCount: originalRecipe.likeCount,
            tagNames: nil, // We'll use tagsToAdd and tagsToDelete instead
            tagsToAdd: tagsToAdd.isEmpty ? nil : tagsToAdd,
            tagsToDelete: tagsToDelete.isEmpty ? nil : tagsToDelete
        )
        
        UpdateRecipeAction(recipeId: originalRecipe.id, parameters: request).call { [weak self] updatedRecipe in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let recipe = updatedRecipe {
                    print("Recipe updated successfully: \(recipe.title)")
                    completion(true)
                } else {
                    self?.errorMessage = "Failed to update recipe. Please try again."
                    completion(false)
                }
            }
        }
    }
} 