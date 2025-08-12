import Foundation

struct RecipeBook: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let isPublic: Bool
    let userId: Int
    let recipeIds: [Int]
    
    // Computed properties
    var displayName: String {
        return name
    }
    
    var isPrivate: Bool {
        return !isPublic
    }
    
    var recipeCount: Int {
        return recipeIds.count
    }
} 
