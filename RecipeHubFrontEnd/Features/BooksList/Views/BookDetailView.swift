//
//  BookDetailView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct BookDetailView: View {
    let book: RecipeBook
    @ObservedObject var viewModel: RecipeBooksViewModel
    @State private var showingAddRecipe = false
    
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.95, blue: 0.97)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Book Header
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(book.displayName)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                                
                                Text("Recipe Collection")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Privacy indicator
                            HStack(spacing: 4) {
                                Image(systemName: book.isPublic ? "globe" : "lock")
                                    .foregroundColor(book.isPublic ? .green : .orange)
                                Text(book.isPublic ? "Public" : "Private")
                                    .font(.caption)
                                    .foregroundColor(book.isPublic ? .green : .orange)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .cornerRadius(20)
                        }
                        
                        Text(book.description)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.purple)
                                Text("\(book.recipeCount) recipe\(book.recipeCount == 1 ? "" : "s")")
                                    .font(.subheadline)
                                    .foregroundColor(.purple)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // Recipes Section
                    VStack(spacing: 16) {
                        HStack {
                            Text("Recipes")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                            
                            Spacer()
                            
                            Button(action: { showingAddRecipe = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.purple)
                                    .font(.title2)
                            }
                        }
                        
                        if book.recipeIds.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                                
                                Text("No recipes yet")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text("Add your first recipe to this book")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(40)
                            .background(Color.white)
                            .cornerRadius(16)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(book.recipeIds, id: \.self) { recipeId in
                                    // TODO: Fetch recipe details by ID
                                    // For now, show a placeholder
                                    HStack {
                                        Text("Recipe #\(recipeId)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Book Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddRecipe) {
            AddRecipeToBookView(book: book, viewModel: viewModel)
        }
    }
}

struct AddRecipeToBookView: View {
    let book: RecipeBook
    @ObservedObject var viewModel: RecipeBooksViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var homeViewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                if homeViewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        Text("Loading your recipes...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else if !homeViewModel.errorMessage.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text(homeViewModel.errorMessage)
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            Text("Add Recipe to '\(book.displayName)'")
                                .font(.headline)
                                .foregroundColor(.purple)
                                .padding(.top)
                            
                            if homeViewModel.recipes.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray)
                                    
                                    Text("No recipes found")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    
                                    Text("Create some recipes first to add them to your book")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(40)
                            } else {
                                ForEach(homeViewModel.recipes) { recipe in
                                    Button(action: {
                                        viewModel.addRecipeToBook(recipe, bookId: book.id)
                                        dismiss()
                                    }) {
                                        RecipeCardView(recipe: recipe)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
        }
        .onAppear {
            homeViewModel.loadUserRecipes(userId: authViewModel.getCurrentUserId())
        }
    }
}

#Preview {
    NavigationView {
        BookDetailView(book: RecipeBook.sample, viewModel: RecipeBooksViewModel())
    }
} 