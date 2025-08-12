import Foundation

enum SearchType: String, CaseIterable {
    case recipeTitle = "Recipe Title"
    case author = "Author"
    
    var endpoint: String {
        switch self {
        case .recipeTitle:
            return "title"
        case .author:
            return "author"
        }
    }
    
    var placeholder: String {
        switch self {
        case .recipeTitle:
            return "Search recipes..."
        case .author:
            return "Search by author..."
        }
    }
} 