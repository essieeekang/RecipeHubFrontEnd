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
        loadSampleBooks()
    }
    
    func loadUserBooks(userId: Int?) {
        guard let userId = userId else {
            print("No user ID available")
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        print("Loading recipe books for user ID: \(userId)")
        
        // TODO: Replace with actual API call
        // For now, filter sample books to show only user's books
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.books = RecipeBook.sampleBooks.filter { $0.authorId == userId }
            self.isLoading = false
            
            if self.books.isEmpty {
                self.errorMessage = "No recipe books found. Create your first book!"
            }
        }
    }
    
    func loadSampleBooks() {
        books = RecipeBook.sampleBooks
    }
    
    func createBook(name: String, description: String, isPublic: Bool, authorId: Int, authorUsername: String) {
        let newBook = RecipeBook(
            id: books.count + 1, // This should come from server
            name: name,
            description: description,
            isPublic: isPublic,
            authorId: authorId,
            authorUsername: authorUsername,
            recipeCount: 0,
            createdAt: Date(),
            updatedAt: Date(),
            recipes: []
        )
        
        DispatchQueue.main.async {
            self.books.append(newBook)
            self.showingCreateBook = false
        }
    }
    
    func deleteBook(_ book: RecipeBook) {
        DispatchQueue.main.async {
            if let index = self.books.firstIndex(where: { $0.id == book.id }) {
                self.books.remove(at: index)
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
        DispatchQueue.main.async {
            if let index = self.books.firstIndex(where: { $0.id == bookId }) {
                let updatedBook = self.books[index]
                var updatedRecipes = updatedBook.recipes
                updatedRecipes.append(recipe)
                
                let newBook = RecipeBook(
                    id: updatedBook.id,
                    name: updatedBook.name,
                    description: updatedBook.description,
                    isPublic: updatedBook.isPublic,
                    authorId: updatedBook.authorId,
                    authorUsername: updatedBook.authorUsername,
                    recipeCount: updatedRecipes.count,
                    createdAt: updatedBook.createdAt,
                    updatedAt: Date(),
                    recipes: updatedRecipes
                )
                
                self.books[index] = newBook
            }
        }
    }
    
    func removeRecipeFromBook(_ recipe: Recipe, bookId: Int) {
        DispatchQueue.main.async {
            if let index = self.books.firstIndex(where: { $0.id == bookId }) {
                var updatedBook = self.books[index]
                let updatedRecipes = updatedBook.recipes.filter { $0.id != recipe.id }
                
                let newBook = RecipeBook(
                    id: updatedBook.id,
                    name: updatedBook.name,
                    description: updatedBook.description,
                    isPublic: updatedBook.isPublic,
                    authorId: updatedBook.authorId,
                    authorUsername: updatedBook.authorUsername,
                    recipeCount: updatedRecipes.count,
                    createdAt: updatedBook.createdAt,
                    updatedAt: Date(),
                    recipes: updatedRecipes
                )
                
                self.books[index] = newBook
            }
        }
    }
    
    func refreshBooks(userId: Int?) {
        loadUserBooks(userId: userId)
    }
} 
