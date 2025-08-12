import SwiftUI

struct RecipeDetailView: View {
    @ObservedObject var viewModel: RecipeDetailViewModel
    @State private var showingForkSheet = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var shouldNavigateToHome = false
    @State private var showingOriginalRecipe = false
    @State private var originalRecipe: Recipe?
    @State private var isLoadingOriginalRecipe = false
    @State private var originalRecipeError: String?
    @State private var originalRecipeId: Int?
    
    
    @StateObject private var globalRecipeHolder = GlobalRecipeHolder.shared
    

    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    let onRecipeDeleted: (() -> Void)?
    
    init(viewModel: RecipeDetailViewModel, onRecipeDeleted: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onRecipeDeleted = onRecipeDeleted
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        ZStack {
            Color(red: 1.0, green: 0.95, blue: 0.97)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
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
                    
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.recipe.title)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                                
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
                                        
                                        Button(action: {
                                            navigateToOriginalRecipe(originalRecipeId)
                                        }) {
                                            Text("Original Recipe ID: #\(originalRecipeId)")
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                                .underline()
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Text("Forked by: \(viewModel.recipe.authorUsername)")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            if let currentUserId = authViewModel.getCurrentUserId() {
                                if currentUserId == viewModel.recipe.authorId {
                                    HStack(spacing: 8) {
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
                        .sheet(isPresented: $showingOriginalRecipe) {
                Group {
                    if globalRecipeHolder.currentOriginalLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                .scaleEffect(1.2)
                            
                            Text("Loading original recipe...")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            Text("Debug: Using global loading state")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(red: 1.0, green: 0.95, blue: 0.97))
                        
                    } else if let recipe = globalRecipeHolder.currentOriginalRecipe {
                        VStack {
                            RecipeDetailView(viewModel: RecipeDetailViewModel(recipe: recipe))
                            
                            Button("Close") {
                                showingOriginalRecipe = false
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.purple)
                            .padding()
                        }
                        
                    } else if let error = globalRecipeHolder.currentOriginalError {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 48))
                                .foregroundColor(.orange)
                            
                            Text("Recipe Not Found")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            
                            Text("Debug: Using global error state")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button("Close") {
                                showingOriginalRecipe = false
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.purple)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(red: 1.0, green: 0.95, blue: 0.97))
                        
                    } else {
                        // No data available - show debug info
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 48))
                                .foregroundColor(.red)
                            
                            Text("No Data Available")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text("Debug: Global state is empty")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("globalLoading: \(globalRecipeHolder.currentOriginalLoading)")
                                Text("globalRecipe: \(globalRecipeHolder.currentOriginalRecipe != nil ? "exists" : "nil")")
                                Text("globalError: \(globalRecipeHolder.currentOriginalError ?? "nil")")
                            }
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color.gray.opacity(0.0))
                            .cornerRadius(8)
                            
                            Button("Close") {
                                showingOriginalRecipe = false
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(red: 1.0, green: 0.95, blue: 0.97))
                    }
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
                onRecipeDeleted?()
                dismiss()
            } else {
                print("Failed to delete recipe")
            }
        }
    }
    
    private func navigateToOriginalRecipe(_ recipeId: Int) {
        fetchOriginalRecipe(recipeId: recipeId)
    }
    
    private func fetchOriginalRecipe(recipeId: Int) {
        isLoadingOriginalRecipe = true
        originalRecipeError = nil
        originalRecipe = nil
        originalRecipeId = recipeId
        
        globalRecipeHolder.setLoading(true)
        
        GetRecipeByIdAction(recipeId: recipeId).call { recipe in
            if let recipe = recipe {
                print("   - Recipe title: \(recipe.title)")
            }
            
            DispatchQueue.main.async {
                self.isLoadingOriginalRecipe = false
                
                if let recipe = recipe {
                    self.originalRecipe = recipe
                    
                    self.globalRecipeHolder.setRecipe(recipe)
                    
                } else {
                    self.originalRecipeError = "Failed to fetch original recipe. It may have been deleted or is no longer available."
                    print("❌ Set originalRecipeError")
                    
                    if let errorMessage = self.originalRecipeError {
                        self.globalRecipeHolder.setError(errorMessage)
                        print("Set global state - error: \(errorMessage)")
                    } else {
                        self.globalRecipeHolder.setError("Unknown error occurred")
                        print("Set global state - fallback error")
                    }
                }
                
                if self.globalRecipeHolder.currentOriginalRecipe != nil || self.globalRecipeHolder.currentOriginalError != nil {
                    // Add a small delay to ensure state is synchronized
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.showingOriginalRecipe = true
                    }
                } else {
                    print("❌ Not ready to show sheet - no global data")
                }
            }
        }
    }
}
