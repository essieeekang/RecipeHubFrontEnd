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
        print("=== addRecipeToBook Debug ===")
        print("Looking for book with ID: \(bookId)")
        print("Current books in viewModel: \(books.map { "\($0.name) (ID: \($0.id))" })")
        print("Total books count: \(books.count)")
        
        // Find the current book to get its existing data
        guard let currentBook = books.first(where: { $0.id == bookId }) else {
            print("❌ Book not found with ID: \(bookId)")
            print("Available book IDs: \(books.map { $0.id })")
            return
        }
        
        print("✅ Found book: \(currentBook.name) (ID: \(currentBook.id))")
        print("Current recipe IDs: \(currentBook.recipeIds)")
        
        // Create new recipe IDs array with the new recipe
        var updatedRecipeIds = currentBook.recipeIds
        if !updatedRecipeIds.contains(recipe.id) {
            updatedRecipeIds.append(recipe.id)
            print("➕ Adding recipe ID: \(recipe.id)")
        } else {
            print("⚠️ Recipe ID \(recipe.id) already exists in book")
        }
        
        print("Updated recipe IDs: \(updatedRecipeIds)")
        
        let request = UpdateRecipeBookRequest(
            name: nil, // Keep existing name
            description: nil, // Keep existing description
            isPublic: nil, // Keep existing privacy setting
            recipeIds: updatedRecipeIds // Update with new recipe IDs
        )
        
        UpdateRecipeBookAction(bookId: bookId, parameters: request).call { [weak self] updatedBook in
            DispatchQueue.main.async {
                if let newBook = updatedBook {
                    // Update the local book data with the server response
                    if let index = self?.books.firstIndex(where: { $0.id == bookId }) {
                        self?.books[index] = newBook
                        print("✅ Successfully updated recipe book: \(newBook.name) with \(newBook.recipeIds.count) recipes")
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
        // Find the current book to get its existing data
        guard let currentBook = books.first(where: { $0.id == bookId }) else {
            print("Book not found with ID: \(bookId)")
            return
        }
        
        // Create new recipe IDs array without the recipe
        var updatedRecipeIds = currentBook.recipeIds
        updatedRecipeIds.removeAll { $0 == recipe.id }
        
        print("Removing recipe \(recipe.title) (ID: \(recipe.id)) from book '\(currentBook.name)' (ID: \(bookId))")
        print("Updated recipe IDs: \(updatedRecipeIds)")
        
        let request = UpdateRecipeBookRequest(
            name: nil, // Keep existing name
            description: nil, // Keep existing description
            isPublic: nil, // Keep existing privacy setting
            recipeIds: updatedRecipeIds // Update with recipe IDs minus the removed one
        )
        
        UpdateRecipeBookAction(bookId: bookId, parameters: request).call { [weak self] updatedBook in
            DispatchQueue.main.async {
                if let newBook = updatedBook {
                    // Update the local book data with the server response
                    if let index = self?.books.firstIndex(where: { $0.id == bookId }) {
                        self?.books[index] = newBook
                        print("Successfully updated recipe book: \(newBook.name) with \(newBook.recipeIds.count) recipes")
                    }
                } else {
                    print("Failed to update recipe book")
                }
            }
        }
    }
} 
