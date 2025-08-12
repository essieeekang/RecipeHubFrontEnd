import Foundation

class RecipeBooksViewModel: ObservableObject {
    @Published var books: [RecipeBook] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showingCreateBook = false
    @Published var selectedBook: RecipeBook?
    
    init() {
        books = []
    }
    
    func loadUserBooks(userId: Int?) {
        guard let userId = userId else {
            print("No user ID available")
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = ""
                
        GetUserRecipeBooksAction(userId: userId).call { [weak self] recipeBooks in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if recipeBooks.isEmpty {
                    self?.errorMessage = "No recipe books found. Create your first book!"
                    self?.books = []
                } else {
                    self?.books = recipeBooks
                    self?.errorMessage = ""
                    print("Loaded \(recipeBooks.count) recipe books for user \(userId)")
                }
            }
        }
    }
    
    func refreshBooks(userId: Int?) {
        loadUserBooks(userId: userId)
    }
    
    func createBook(name: String, description: String, isPublic: Bool, authorId: Int, authorUsername: String, completion: @escaping (Bool) -> Void) {
        let request = CreateRecipeBookRequest(
            name: name,
            description: description,
            isPublic: isPublic,
            userId: authorId,
            recipeIds: []
        )
                
        CreateRecipeBookAction(parameters: request).call { [weak self] recipeBook in
            DispatchQueue.main.async {
                if let newBook = recipeBook {

                    self?.books.append(newBook)
                    
                    completion(true)
                } else {
                    print("Failed to create recipe book")
                    completion(false)
                }
            }
        }
    }
    
    func deleteBook(_ book: RecipeBook, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
                
        DeleteRecipeBookAction(bookId: book.id).call { [weak self] success in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success {
                    self?.books.removeAll { $0.id == book.id }
                    completion(true)
                } else {
                    print("Failed to delete recipe book: \(book.name)")
                    self?.errorMessage = "Failed to delete recipe book. Please try again."
                    completion(false)
                }
            }
        }
    }
    
    func updateBook(_ book: RecipeBook) {
        DispatchQueue.main.async {
            if let index = self.books.firstIndex(where: { $0.id == book.id }) {
                self.books[index] = book
            }
        }
    }
    
    func addRecipeToBook(_ recipe: Recipe, bookId: Int) {
        guard let currentBook = books.first(where: { $0.id == bookId }) else {
            print("❌ Book not found with ID: \(bookId)")
            return
        }
        
        var updatedRecipeIds = currentBook.recipeIds
        if !updatedRecipeIds.contains(recipe.id) {
            updatedRecipeIds.append(recipe.id)
        }
        
        
        let request = UpdateRecipeBookRequest(
            name: nil,
            description: nil,
            isPublic: nil,
            recipeIds: updatedRecipeIds
        )
        
        UpdateRecipeBookAction(bookId: bookId, parameters: request).call { [weak self] updatedBook in
            DispatchQueue.main.async {
                if let newBook = updatedBook {
                    if let index = self?.books.firstIndex(where: { $0.id == bookId }) {
                        self?.books[index] = newBook
                    } else {
                        print("❌ Could not find book index for ID: \(bookId)")
                    }
                } else {
                    print("❌ Failed to update recipe book")
                }
            }
        }
    }
    
    func removeRecipeFromBook(_ recipe: Recipe, bookId: Int) {
        guard let currentBook = books.first(where: { $0.id == bookId }) else {
            print("Book not found with ID: \(bookId)")
            return
        }
        
        var updatedRecipeIds = currentBook.recipeIds
        updatedRecipeIds.removeAll { $0 == recipe.id }
        
        let request = UpdateRecipeBookRequest(
            name: nil,
            description: nil,
            isPublic: nil,
            recipeIds: updatedRecipeIds
        )
        
        UpdateRecipeBookAction(bookId: bookId, parameters: request).call { [weak self] updatedBook in
            DispatchQueue.main.async {
                if let newBook = updatedBook {
                    if let index = self?.books.firstIndex(where: { $0.id == bookId }) {
                        self?.books[index] = newBook
                    }
                } else {
                    print("Failed to update recipe book")
                }
            }
        }
    }
    
    func editRecipeBook(bookId: Int, name: String?, description: String?, isPublic: Bool?, recipeIds: [Int]?, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
        
        let request = UpdateRecipeBookRequest(
            name: name,
            description: description,
            isPublic: isPublic,
            recipeIds: recipeIds
        )
        
        UpdateRecipeBookAction(bookId: bookId, parameters: request).call { [weak self] updatedBook in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let book = updatedBook {
                    
                    if let index = self?.books.firstIndex(where: { $0.id == bookId }) {
                        self?.books[index] = book
                    }
                    
                    completion(true)
                } else {
                    print("Failed to update recipe book")
                    self?.errorMessage = "Failed to update recipe book. Please try again."
                    completion(false)
                }
            }
        }
    }
} 
