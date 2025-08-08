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
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.95, blue: 0.97)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
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
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.triangle.branch")
                                            .foregroundColor(.purple)
                                            .font(.caption)
                                        Text("Forked from recipe #\(originalRecipeId)")
                                            .font(.caption)
                                            .foregroundColor(.purple)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Fork button (only show if recipe is not by current user)
                            if let currentUserId = authViewModel.getCurrentUserId(), currentUserId != viewModel.recipe.authorId {
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
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingForkSheet) {
            AddRecipeView(recipeToFork: viewModel.recipe)
        }
    }
}
#Preview {
    RecipeDetailView(viewModel: .init(recipe: .sample))
}
