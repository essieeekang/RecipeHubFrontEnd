import Foundation

struct SearchResponse: Codable {
    let authorId: Int?
    let recipes: [Recipe]?
    let recipeBooks: [RecipeBook]?
    let totalRecipes: Int?
    let totalRecipeBooks: Int?
    
    var recipeResults: [Recipe] {
        return recipes ?? []
    }
} 
