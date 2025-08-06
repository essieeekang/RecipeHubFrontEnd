//
//  HomeViewModel.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    init() {
        // Start with empty recipes - will be loaded when user logs in
        recipes = []
    }
    
    func loadUserRecipes(userId: Int?) {
        guard let userId = userId else {
            print("No user ID available")
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        print("Loading recipes for user ID: \(userId)")
        
        GetUserRecipesAction(userId: userId).call { [weak self] recipes in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if recipes.isEmpty {
                    self?.errorMessage = "No recipes found. Create your first recipe!"
                    self?.recipes = []
                } else {
                    self?.recipes = recipes
                    self?.errorMessage = ""
                    print("Loaded \(recipes.count) recipes for user \(userId)")
                }
            }
        }
    }
    
    func refreshRecipes(userId: Int?) {
        loadUserRecipes(userId: userId)
    }
    
    func addRecipe(_ recipe: Recipe) {
        DispatchQueue.main.async {
            self.recipes.append(recipe)
            print("Added new recipe to list: \(recipe.title)")
        }
    }
    
    func removeRecipe(at index: Int) {
        if index < recipes.count {
            recipes.remove(at: index)
        }
    }
    
    func updateRecipe(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
        }
    }
}
