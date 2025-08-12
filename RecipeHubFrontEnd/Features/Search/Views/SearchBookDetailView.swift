import SwiftUI

struct SearchBookDetailView: View {
    let recipeBook: RecipeBook
    @StateObject private var homeViewModel = HomeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
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
                                Text(recipeBook.displayName)
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
                                Image(systemName: recipeBook.isPublic ? "globe" : "lock")
                                    .foregroundColor(recipeBook.isPublic ? .green : .orange)
                                Text(recipeBook.isPublic ? "Public" : "Private")
                                    .font(.caption)
                                    .foregroundColor(recipeBook.isPublic ? .green : .orange)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .cornerRadius(20)
                        }
                        
                        Text(recipeBook.description)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.purple)
                                Text("\(recipeBook.recipeCount) recipe\(recipeBook.recipeCount == 1 ? "" : "s")")
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
                        }
                        
                        if recipeBook.recipeIds.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                                
                                Text("No recipes yet")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text("This recipe book is empty")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(40)
                            .background(Color.white)
                            .cornerRadius(16)
                        } else {
                            // Display actual recipe cards
                            if homeViewModel.isLoading {
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                    Text("Loading recipes...")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(40)
                            } else if !homeViewModel.errorMessage.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 48))
                                        .foregroundColor(.orange)
                                    
                                    Text("Error loading recipes")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    
                                    Text(homeViewModel.errorMessage)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(40)
                            } else {
                                // Filter recipes to only show those in the book
                                let bookRecipes = homeViewModel.recipes.filter { recipe in
                                    recipeBook.recipeIds.contains(recipe.id)
                                }
                                
                                if bookRecipes.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "doc.text")
                                            .font(.system(size: 48))
                                            .foregroundColor(.gray)
                                        
                                        Text("No recipes found")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                        
                                        Text("The recipes in this book may have been deleted")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(40)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                } else {
                                    VStack(spacing: 12) {
                                        ForEach(bookRecipes) { recipe in
                                            NavigationLink(destination: RecipeDetailView(viewModel: RecipeDetailViewModel(recipe: recipe))) {
                                                RecipeCardView(recipe: recipe)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
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
        .onAppear {
            // Load all user recipes to display the ones in this book
            // For search results, we'll need to get the user ID from the recipe book
            homeViewModel.loadUserRecipes(userId: recipeBook.userId)
        }
    }
}

#Preview {
    SearchBookDetailView(recipeBook: RecipeBook.sample)
        .environmentObject(AuthViewModel())
} 