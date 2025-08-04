//
//  AddRecipeViewModel.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

class AddRecipeViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var ingredients: [IngredientInput] = [IngredientInput()]
    @Published var instructions: [String] = [""]
    @Published var isPublic = true
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var isRecipeCreated = false
    
    struct IngredientInput: Identifiable {
        let id = UUID()
        var name = ""
        var quantity = ""
        var unit = ""
    }
    
    var canSubmit: Bool {
        !title.isEmpty && 
        !description.isEmpty && 
        !ingredients.isEmpty && 
        ingredients.allSatisfy { !$0.name.isEmpty && !$0.quantity.isEmpty } &&
        !instructions.isEmpty && 
        instructions.allSatisfy { !$0.isEmpty }
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
    
    func createRecipe() {
        guard canSubmit else {
            errorMessage = "Please fill in all required fields"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Convert ingredients to the proper format
        let formattedIngredients = ingredients.compactMap { ingredient -> Ingredient? in
            guard let quantity = Double(ingredient.quantity) else { return nil }
            return Ingredient(name: ingredient.name, unit: ingredient.unit, quantity: quantity)
        }
        
        // Filter out empty instructions
        let filteredInstructions = instructions.filter { !$0.isEmpty }
        
        // Create the recipe object
        let recipe = Recipe(
            id: 0, // Will be set by server
            title: title,
            description: description,
            ingredients: formattedIngredients,
            instructions: filteredInstructions,
            isPublic: isPublic,
            cooked: false,
            favourite: false,
            likeCount: 0,
            authorId: 0, // Will be set by server
            authorUsername: "", // Will be set by server
            originalRecipeId: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // TODO: Add API call to create recipe
        print("Creating recipe: \(recipe.title)")
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.isRecipeCreated = true
        }
    }
    
    func resetForm() {
        title = ""
        description = ""
        ingredients = [IngredientInput()]
        instructions = [""]
        isPublic = true
        errorMessage = ""
        isRecipeCreated = false
    }
} 