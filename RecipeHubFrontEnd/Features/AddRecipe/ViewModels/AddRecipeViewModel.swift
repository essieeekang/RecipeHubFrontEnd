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
        
        let recipeIngredients = ingredients.map { input in
            Ingredient(name: input.name, unit: input.unit, quantity: input.quantity)
        }
        
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
        
        CreateRecipeAction(parameters: request).call { [weak self] newRecipe in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let recipe = newRecipe {
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
    }
    
    func populateWithRecipe(_ recipe: Recipe, currentUserId: Int) {
        if recipe.authorId == currentUserId {
            print("Cannot fork your own recipe")
            return
        }
        
        originalRecipe = recipe
        isForking = true
        
        title = "\(recipe.title) (Forked)"
        description = recipe.description
        isPublic = recipe.isPublic
        cooked = recipe.cooked
        favourite = recipe.favourite
        
        ingredients = recipe.ingredients.map { ingredient in
            IngredientInput(name: ingredient.name, unit: ingredient.unit, quantity: ingredient.quantity)
        }
        
        if ingredients.isEmpty {
            ingredients = [IngredientInput()]
        }
        
        instructions = recipe.instructions
        
        if instructions.isEmpty {
            instructions = [""]
        }
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
            authorId: authorId,
            originalRecipeId: originalRecipe.id
        )
                
        ForkRecipeAction(recipeId: originalRecipe.id, parameters: request).call { [weak self] forkedRecipe in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let newRecipe = forkedRecipe {
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
