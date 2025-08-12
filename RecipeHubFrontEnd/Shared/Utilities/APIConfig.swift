import Foundation

struct APIConfig {
    static let baseURL = "http://192.168.0.166:8080"
    static let productionBaseURL = "https://back-end-recipe-hub.onrender.com"
    
    struct Endpoints {
        // User endpoints
        static let users = "/api/users"
        static let userRecipes = "/api/users/{userId}/recipes"
        static let userFavoriteRecipes = "/api/users/{userId}/recipes/favourite"
        static let userCookedRecipes = "/api/users/{userId}/recipes/cooked"
        static let userRecipeBooks = "/api/users/{userId}/recipe-books"
        
        // Recipe endpoints
        static let recipes = "/api/recipes"
        static let recipeSearch = "/api/recipes/search"
        
        // Recipe Book endpoints
        static let recipeBooks = "/api/recipebooks"
    }
    
    static func buildURL(for endpoint: String, pathParameters: [String: String] = [:], queryParameters: [String: String] = [:]) -> URL? {
        var urlString = environmentBaseURL + endpoint
        
        // Replace path parameters
        for (key, value) in pathParameters {
            urlString = urlString.replacingOccurrences(of: "{\(key)}", with: value)
        }
        
        // Add query parameters
        if !queryParameters.isEmpty {
            let queryString = queryParameters
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "&")
            urlString += "?\(queryString)"
        }
        
        return URL(string: urlString)
    }
    
    static func userRecipesURL(userId: String) -> URL? {
        return buildURL(for: Endpoints.userRecipes, pathParameters: ["userId": userId])
    }
    
    static func userFavoriteRecipesURL(userId: String) -> URL? {
        return buildURL(for: Endpoints.userFavoriteRecipes, pathParameters: ["userId": userId])
    }
    
    static func userCookedRecipesURL(userId: String) -> URL? {
        return buildURL(for: Endpoints.userCookedRecipes, pathParameters: ["userId": userId])
    }
    
    static func userRecipeBooksURL(userId: String) -> URL? {
        return buildURL(for: Endpoints.userRecipeBooks, pathParameters: ["userId": userId])
    }
    
    static func recipesURL() -> URL? {
        return buildURL(for: Endpoints.recipes)
    }
    
    static func recipeURL(recipeId: String) -> URL? {
        return buildURL(for: Endpoints.recipes + "/{recipeId}", pathParameters: ["recipeId": recipeId])
    }
    
    static func forkRecipeURL(recipeId: String) -> URL? {
        return buildURL(for: Endpoints.recipes + "/{recipeId}/fork", pathParameters: ["recipeId": recipeId])
    }
    
    static func recipeSearchURL(searchType: String, searchTerm: String) -> URL? {
        return buildURL(for: Endpoints.recipeSearch, queryParameters: [searchType: searchTerm])
    }
    
    static func recipeBooksURL() -> URL? {
        return buildURL(for: Endpoints.recipeBooks)
    }
    
    static func recipeBookURL(bookId: String) -> URL? {
        return buildURL(for: Endpoints.recipeBooks + "/{bookId}", pathParameters: ["bookId": bookId])
    }
    
    static func userURL(userId: String) -> URL? {
        return buildURL(for: Endpoints.users + "/{userId}", pathParameters: ["userId": userId])
    }
}

// MARK: - Environment Configuration
extension APIConfig {
    enum Environment: String, CaseIterable {
        case development = "Development"
        case production = "Production"
        
        var baseURL: String {
            switch self {
            case .development:
                return "http://192.168.0.166:8080"
            case .production:
                return "https://back-end-recipe-hub.onrender.com"
            }
        }
        
        var displayName: String {
            return rawValue
        }
    }
    
    // Change this to switch environments - this is for development purposes only
    static var currentEnvironment: Environment = .development
    
    // Computed property that uses the current environment
    static var environmentBaseURL: String {
        return currentEnvironment.baseURL
    }
}
