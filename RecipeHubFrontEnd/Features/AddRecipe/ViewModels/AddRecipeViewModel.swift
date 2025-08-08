//
//  AddRecipeViewModel.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation
import UIKit

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
    
    // Forking properties
    @Published var isForking = false
    @Published var originalRecipe: Recipe?
    
    // Image selection properties
    @Published var selectedImage: UIImage?
    @Published var showingImagePicker = false
    @Published var showingCamera = false
    @Published var showingImageOptions = false
    
    var canSubmit: Bool {
        !title.isEmpty && 
        !ingredients.isEmpty && 
        ingredients.allSatisfy { !$0.name.isEmpty && !$0.unit.isEmpty && $0.quantity > 0 } &&
        !instructions.isEmpty && 
        instructions.allSatisfy { !$0.isEmpty } &&
        !isLoading
    }
    
    var submitButtonTitle: String {
        if isForking {
            return isLoading ? "Forking..." : "Fork Recipe"
        } else {
            return isLoading ? "Creating..." : "Create Recipe"
        }
    }
    
    var navigationTitle: String {
        return isForking ? "Fork Recipe" : "Create Recipe"
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
    
    func addImage() {
        showingImageOptions = true
    }
    
    func selectFromLibrary() {
        showingImagePicker = true
        showingImageOptions = false
    }
    
    func takePhoto() {
        showingCamera = true
        showingImageOptions = false
    }
    
    func removeImage() {
        selectedImage = nil
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
        
        // Convert image to Data if selected
        var imageData: Data?
        var imageFileName: String?
        
        if let image = selectedImage {
            imageData = image.jpegData(compressionQuality: 0.8)
            imageFileName = "recipe_image_\(Date().timeIntervalSince1970).jpg"
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
            originalRecipeId: nil,
            imageData: imageData,
            imageFileName: imageFileName
        )
        
        print("Creating recipe: \(title)")
        if imageData != nil {
            print("Including image: \(imageFileName ?? "unknown")")
        }
        
        CreateRecipeAction(parameters: request).call { [weak self] newRecipe in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let recipe = newRecipe {
                    print("Successfully created recipe: \(recipe.title) with ID: \(recipe.id)")
                    self?.createdRecipe = recipe
                    self?.isRecipeCreated = true
                    self?.resetForm()
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
        selectedImage = nil
        // Note: createdRecipe is not cleared here as it's needed for the alert
    }
    
    func populateWithRecipe(_ recipe: Recipe, currentUserId: Int) {
        // Prevent forking your own recipes
        if recipe.authorId == currentUserId {
            print("Cannot fork your own recipe")
            return
        }
        
        originalRecipe = recipe
        isForking = true
        
        // Populate form with recipe data
        title = "\(recipe.title) (Forked)"
        description = recipe.description
        isPublic = recipe.isPublic
        cooked = recipe.cooked
        favourite = recipe.favourite
        
        // Convert ingredients
        ingredients = recipe.ingredients.map { ingredient in
            IngredientInput(name: ingredient.name, unit: ingredient.unit, quantity: ingredient.quantity)
        }
        
        // If no ingredients, add one empty
        if ingredients.isEmpty {
            ingredients = [IngredientInput()]
        }
        
        // Convert instructions
        instructions = recipe.instructions
        
        // If no instructions, add one empty
        if instructions.isEmpty {
            instructions = [""]
        }
        
        print("Populated form with recipe: \(recipe.title)")
    }
    
    func forkRecipe(authorId: Int, completion: @escaping (Bool) -> Void) {
        guard canSubmit else {
            errorMessage = "Please fill in all required fields"
            completion(false)
            return
        }
        
        guard let originalRecipe = originalRecipe else {
            errorMessage = "No original recipe to fork"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Convert IngredientInput to Ingredient
        let recipeIngredients = ingredients.map { input in
            Ingredient(name: input.name, unit: input.unit, quantity: input.quantity)
        }
        
        let request = ForkRecipeRequest(
            title: title,
            description: description,
            ingredients: recipeIngredients,
            instructions: instructions.filter { !$0.isEmpty },
            isPublic: isPublic,
            cooked: cooked,
            favourite: favourite,
            authorId: authorId
        )
        
        print("Forking recipe: \(title) from original: \(originalRecipe.title)")
        
        ForkRecipeAction(recipeId: originalRecipe.id, parameters: request).call { [weak self] forkedRecipe in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let newRecipe = forkedRecipe {
                    print("Successfully forked recipe: \(newRecipe.title) with ID: \(newRecipe.id)")
                    self?.createdRecipe = newRecipe
                    self?.isRecipeCreated = true
                    self?.resetForm()
                    completion(true)
                } else {
                    print("Failed to fork recipe")
                    self?.errorMessage = "Failed to fork recipe. Please try again."
                    completion(false)
                }
            }
        }
    }
} 