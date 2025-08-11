//
//  RecipeDetailView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 8/1/25.
//

import SwiftUI

struct RecipeDetailView: View {
    @ObservedObject var viewModel: RecipeDetailViewModel
    @State private var showingForkSheet = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @EnvironmentObject var authViewModel: AuthViewModel
    let onRecipeDeleted: (() -> Void)?
    
    init(viewModel: RecipeDetailViewModel, onRecipeDeleted: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onRecipeDeleted = onRecipeDeleted
    }
    
    // MARK: - Computed Properties
    
    @ViewBuilder
    private var mainContentView: some View {
        ZStack {
            Color(red: 1.0, green: 0.95, blue: 0.97)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Recipe Image (if available)
                    if let imageUrl = viewModel.recipe.imageUrl, !imageUrl.isEmpty {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                )
                        }
                        .cornerRadius(16)
                    }
                    
                    // Recipe Header
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.recipe.title)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                                
                                // Show forking information if this is a forked recipe
                                if let originalRecipeId = viewModel.recipe.originalRecipeId {
                                    VStack(spacing: 4) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.triangle.branch")
                                                .foregroundColor(.purple)
                                                .font(.caption)
                                            Text("Forked Recipe")
                                                .font(.caption)
                                                .foregroundColor(.purple)
                                        }
                                        
                                        Text("Original Recipe ID: #\(originalRecipeId)")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                        
                                        Text("Forked by: \(viewModel.recipe.authorUsername)")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Action buttons
                            if let currentUserId = authViewModel.getCurrentUserId() {
                                if currentUserId == viewModel.recipe.authorId {
                                    // Author buttons
                                    HStack(spacing: 8) {
                                        // Edit button
                                        Button(action: {
                                            showingEditSheet = true
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "pencil")
                                                    .foregroundColor(.purple)
                                                Text("Edit")
                                                    .font(.caption)
                                                    .foregroundColor(.purple)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.purple.opacity(0.1))
                                            .cornerRadius(20)
                                        }
                                        
                                        // Delete button
                                        Button(action: {
                                            showingDeleteAlert = true
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                                Text("Delete")
                                                    .font(.caption)
                                                    .foregroundColor(.red)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(20)
                                        }
                                        .disabled(viewModel.isDeleting)
                                    }
                                } else {
                                    // Non-author button
                                    Button(action: {
                                        showingForkSheet = true
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.triangle.branch")
                                                .foregroundColor(.purple)
                                            Text("Fork")
                                                .font(.caption)
                                                .foregroundColor(.purple)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.purple.opacity(0.1))
                                        .cornerRadius(20)
                                    }
                                }
                            }
                        }
                        
                        Text(viewModel.recipe.description)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                        
                        // Recipe metadata
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: "person.circle")
                                    .foregroundColor(.purple)
                                Text("by \(viewModel.recipe.authorUsername)")
                                    .font(.subheadline)
                                    .foregroundColor(.purple)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                if viewModel.recipe.favourite {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                                
                                if viewModel.recipe.cooked {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                                
                                Text("\(viewModel.recipe.likeCount) like\(viewModel.recipe.likeCount == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        
                        VStack(spacing: 8) {
                            ForEach(viewModel.recipe.ingredients, id: \.name) { ingredient in
                                HStack {
                                    Text("•")
                                        .foregroundColor(.purple)
                                    
                                    Text("\(ingredient.quantity.clean) \(ingredient.unit) \(ingredient.name)")
                                        .font(.body)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    // Instructions Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1).")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.purple)
                                        .frame(width: 30, alignment: .leading)
                                    
                                    Text(instruction)
                                        .font(.body)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    var body: some View {
        mainContentView
            .navigationTitle("Recipe Details")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingForkSheet) {
                AddRecipeView(recipeToFork: viewModel.recipe)
            }
            .sheet(isPresented: $showingEditSheet) {
                EditRecipeView(recipe: viewModel.recipe, authorId: viewModel.recipe.authorId) { updatedRecipe in
                    viewModel.updateRecipe(updatedRecipe)
                }
            }
            .alert("Delete Recipe", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteRecipe()
                }
            } message: {
                Text("Are you sure you want to delete '\(viewModel.recipe.title)'? This action cannot be undone.")
            }
            .overlay(
                Group {
                    if viewModel.isDeleting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .scaleEffect(0.8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(16)
                    }
                }
            )
    }
    
    private func deleteRecipe() {
        viewModel.deleteRecipe { success in
            if success {
                print("Recipe deleted successfully")
                onRecipeDeleted?()
            } else {
                print("Failed to delete recipe")
            }
        }
    }
}

#Preview {
    RecipeDetailView(viewModel: .init(recipe: .sample), onRecipeDeleted: nil)
}
