//
//  RecipeDetailView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 8/1/25.
//

import Foundation

class RecipeDetailViewModel: ObservableObject {
    @Published var recipe: Recipe
    @Published var isDeleting = false
    @Published var errorMessage = ""

    init(recipe: Recipe) {
        self.recipe = recipe
    }
    
    func deleteRecipe(completion: @escaping (Bool) -> Void) {
        isDeleting = true
        errorMessage = ""
        
        print("Deleting recipe: \(recipe.title) with ID: \(recipe.id)")
        
        DeleteRecipeAction(recipeId: recipe.id).call { [weak self] success in
            DispatchQueue.main.async {
                self?.isDeleting = false
                
                if success {
                    print("Successfully deleted recipe: \(self?.recipe.title ?? "")")
                    completion(true)
                } else {
                    print("Failed to delete recipe: \(self?.recipe.title ?? "")")
                    self?.errorMessage = "Failed to delete recipe. Please try again."
                    completion(false)
                }
            }
        }
    }
    
    func updateRecipe(_ updatedRecipe: Recipe) {
        self.recipe = updatedRecipe
        print("Recipe updated successfully: \(updatedRecipe.title)")
    }
}
