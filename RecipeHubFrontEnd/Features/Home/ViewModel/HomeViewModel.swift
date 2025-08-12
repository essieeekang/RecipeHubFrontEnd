import Foundation

enum RecipeFilter: String, CaseIterable {
    case all = "All"
    case favorite = "Favorites"
    case cooked = "Cooked"
    
    var icon: String {
        switch self {
        case .all:
            return "doc.text"
        case .favorite:
            return "heart.fill"
        case .cooked:
            return "checkmark.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .all:
            return "purple"
        case .favorite:
            return "red"
        case .cooked:
            return "green"
        }
    }
}

class HomeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var currentFilter: RecipeFilter = .all
    
    init() {
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
                
        GetUserRecipesAction(userId: userId).call { [weak self] recipes in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if recipes.isEmpty {
                    self?.errorMessage = "No recipes found. Create your first recipe!"
                    self?.recipes = []
                } else {
                    self?.recipes = recipes
                    self?.errorMessage = ""
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
    
    func loadFilteredRecipes(userId: Int?, filter: RecipeFilter) {
        guard let userId = userId else {
            print("No user ID available")
            errorMessage = "User not authenticated"
            return
        }
        
        currentFilter = filter
        isLoading = true
        errorMessage = ""
                
        switch filter {
        case .all:
            loadUserRecipes(userId: userId)
        case .favorite:
            loadFavoriteRecipes(userId: userId)
        case .cooked:
            loadCookedRecipes(userId: userId)
        }
    }
    
    private func loadFavoriteRecipes(userId: Int) {
        GetFavoriteRecipesAction(userId: userId).call { [weak self] recipes in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if recipes.isEmpty {
                    self?.errorMessage = "No favorite recipes found. Mark some recipes as favorites!"
                    self?.recipes = []
                } else {
                    self?.recipes = recipes
                    self?.errorMessage = ""
                    print("Loaded \(recipes.count) favorite recipes for user \(userId)")
                }
            }
        }
    }
    
    private func loadCookedRecipes(userId: Int) {
        GetCookedRecipesAction(userId: userId).call { [weak self] recipes in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if recipes.isEmpty {
                    self?.errorMessage = "No cooked recipes found. Mark some recipes as cooked!"
                    self?.recipes = []
                } else {
                    self?.recipes = recipes
                    self?.errorMessage = ""
                    print("Loaded \(recipes.count) cooked recipes for user \(userId)")
                }
            }
        }
    }
}
