//
//  AddRecipeViewModel.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct IngredientInput: Identifiable {
    let id = UUID()
    var name: String = ""
    var unit: String = ""
    var quantity: Double = 1.0
}

class AddRecipeViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var ingredients: [IngredientInput] = [IngredientInput()]
    @Published var instructions: [String] = [""]
    @Published var isPublic = true
    @Published var cooked = false
    @Published var favourite = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isRecipeCreated = false
    @Published var createdRecipe: Recipe?
    
    var canSubmit: Bool {
        !title.isEmpty && 
        !ingredients.isEmpty && 
        ingredients.allSatisfy { !$0.name.isEmpty && !$0.unit.isEmpty && $0.quantity > 0 } &&
        !instructions.isEmpty && 
        instructions.allSatisfy { !$0.isEmpty } &&
        !isLoading
    }
    
    func addIngredient() {
        ingredients.append(IngredientInput())
    }
    
    func removeIngredient(at index: Int) {
        if ingredients.count > 1 {
            ingredients.remove(at: index)
        }
    }
    
    func addInstruction() {
        instructions.append("")
    }
    
    func removeInstruction(at index: Int) {
        if instructions.count > 1 {
            instructions.remove(at: index)
        }
    }
    
    func createRecipe(authorId: Int, completion: @escaping (Bool) -> Void) {
        guard canSubmit else {
            errorMessage = "Please fill in all required fields"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Convert IngredientInput to Ingredient
        let recipeIngredients = ingredients.map { input in
            Ingredient(name: input.name, unit: input.unit, quantity: input.quantity)
        }
        
        let request = CreateRecipeRequest(
            title: title,
            description: description,
            ingredients: recipeIngredients,
            instructions: instructions.filter { !$0.isEmpty },
            isPublic: isPublic,
            cooked: cooked,
            favourite: favourite,
            authorId: authorId,
            originalRecipeId: nil
        )
        
        print("Creating recipe: \(title)")
        
        CreateRecipeAction(parameters: request).call { [weak self] recipe in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let newRecipe = recipe {
                    print("Successfully created recipe: \(newRecipe.title) with ID: \(newRecipe.id)")
                    self?.createdRecipe = newRecipe // Store before resetting
                    self?.isRecipeCreated = true
                    self?.resetForm() // Reset form after successful creation
                    completion(true)
                } else {
                    print("Failed to create recipe")
                    self?.errorMessage = "Failed to create recipe. Please try again."
                    completion(false)
                }
            }
        }
    }
    
    func resetForm() {
        title = ""
        description = ""
        ingredients = [IngredientInput()]
        instructions = [""]
        isPublic = true
        cooked = false
        favourite = false
        errorMessage = ""
        isRecipeCreated = false
        // Note: createdRecipe is not cleared here as it's needed for the alert
    }
} 