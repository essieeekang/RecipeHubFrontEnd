import Foundation

// Response wrapper for search API based on actual response format
struct SearchResponse: Codable {
    let authorId: Int?
    let recipes: [Recipe]?
    let recipeBooks: [RecipeBook]?
    let totalRecipes: Int?
    let totalRecipeBooks: Int?
    
    // Helper computed property to get recipes
    var recipeResults: [Recipe] {
        return recipes ?? []
    }
} 