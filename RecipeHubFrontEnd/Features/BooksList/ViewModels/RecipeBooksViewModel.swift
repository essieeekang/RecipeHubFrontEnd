//
//  RecipeBooksViewModel.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

class RecipeBooksViewModel: ObservableObject {
    @Published var books: [RecipeBook] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showingCreateBook = false
    @Published var selectedBook: RecipeBook?
    
    init() {
        // Start with empty books - will be loaded when user logs in
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
        
        print("Loading recipe books for user ID: \(userId)")
        
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
        
        print("Creating recipe book: \(name)")
        
        CreateRecipeBookAction(parameters: request).call { [weak self] recipeBook in
            DispatchQueue.main.async {
                if let newBook = recipeBook {
                    print("Successfully created recipe book: \(newBook.name) with ID: \(newBook.id)")
                    print("Current books count before adding: \(self?.books.count ?? 0)")
                    
                    self?.books.append(newBook)
                    
                    print("Current books count after adding: \(self?.books.count ?? 0)")
                    print("Books in array: \(self?.books.map { "\($0.name) (ID: \($0.id))" } ?? [])")
                    
                    completion(true)
                } else {
                    print("Failed to create recipe book")
                    completion(false)
                }
            }
        }
    }
    
    func deleteBook(_ book: RecipeBook) {
        // TODO: Implement API call to delete book
        DispatchQueue.main.async {
            self.books.removeAll { $0.id == book.id }
        }
    }
    
    func updateBook(_ book: RecipeBook) {
        // TODO: Implement API call to update book
        DispatchQueue.main.async {
            if let index = self.books.firstIndex(where: { $0.id == book.id }) {
                self.books[index] = book
            }
        }
    }
    
    func addRecipeToBook(_ recipe: Recipe, bookId: Int) {
        // TODO: Implement API call to add recipe to book
        DispatchQueue.main.async {
            if let index = self.books.firstIndex(where: { $0.id == bookId }) {
                var updatedBook = self.books[index]
                // Note: This would need to be updated when we have the actual API
                // For now, just update the local array
            }
        }
    }
    
    func removeRecipeFromBook(_ recipe: Recipe, bookId: Int) {
        // TODO: Implement API call to remove recipe from book
        DispatchQueue.main.async {
            if let index = self.books.firstIndex(where: { $0.id == bookId }) {
                var updatedBook = self.books[index]
                // Note: This would need to be updated when we have the actual API
                // For now, just update the local array
            }
        }
    }
} 
