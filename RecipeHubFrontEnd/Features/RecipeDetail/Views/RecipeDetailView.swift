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
    @State private var shouldNavigateToHome = false
    @State private var showingOriginalRecipe = false
    @State private var originalRecipe: Recipe?
    @State private var isLoadingOriginalRecipe = false
    @State private var originalRecipeError: String?
    @State private var originalRecipeId: Int?
    
    // Store the data we want to show in the sheet
    @State private var sheetData: SheetData?
    
    // Struct to hold sheet data
    private struct SheetData {
        let recipe: Recipe?
        let error: String?
        let isLoading: Bool
    }
    
    // Alternative approach: store the data in a more stable way
    @State private var currentSheetRecipe: Recipe?
    @State private var currentSheetError: String?
    @State private var currentSheetLoading: Bool = false
    
    // Final approach: use a closure-based sheet with direct data passing
    @State private var sheetContent: SheetContent?
    
    // Enum to represent what should be shown in the sheet
    private enum SheetContent {
        case loading
        case recipe(Recipe)
        case error(String)
        
        var recipe: Recipe? {
            switch self {
            case .recipe(let recipe): return recipe
            default: return nil
            }
        }
        
        var error: String? {
            switch self {
            case .error(let error): return error
            default: return nil
            }
        }
        
        var isLoading: Bool {
            switch self {
            case .loading: return true
            default: return false
            }
        }
    }
    
    // Alternative approach: store the actual data directly in the view
    @State private var capturedRecipe: Recipe?
    @State private var capturedError: String?
    @State private var capturedLoading: Bool = false
    
    // Final approach: use a closure-based sheet that captures data directly
    @State private var originalRecipeData: (recipe: Recipe?, error: String?, isLoading: Bool) = (nil, nil, false)
    
    // Alternative approach: use a more persistent data store
    @State private var persistentRecipe: Recipe?
    @State private var persistentError: String?
    @State private var persistentLoading: Bool = false
    
    // Final approach: use a closure-based sheet that captures data directly
    @State private var sheetRecipe: Recipe?
    @State private var sheetError: String?
    @State private var sheetLoading: Bool = false
    

    
    // Global state approach: use a singleton that survives view recreation
    @StateObject private var globalRecipeHolder = GlobalRecipeHolder.shared
    

    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
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
                                        
                                        Button(action: {
                                            // Navigate to original recipe
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
                        .sheet(isPresented: $showingOriginalRecipe) {
                Group {
                    let _ = print("🔍 Sheet content evaluation:")
                    let _ = print("   - globalLoading: \(globalRecipeHolder.currentOriginalLoading)")
                    let _ = print("   - globalRecipe: \(globalRecipeHolder.currentOriginalRecipe != nil ? "exists" : "nil")")
                    let _ = print("   - globalError: \(globalRecipeHolder.currentOriginalError ?? "nil")")
                    
                    // Use global state that survives view recreation
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
                print("Recipe deleted successfully")
                onRecipeDeleted?()
                // Navigate back to home screen
                dismiss()
            } else {
                print("Failed to delete recipe")
            }
        }
    }
    
    private func navigateToOriginalRecipe(_ recipeId: Int) {
        // Fetch the original recipe and show it
        fetchOriginalRecipe(recipeId: recipeId)
    }
    
    private func fetchOriginalRecipe(recipeId: Int) {
        print("🚀 fetchOriginalRecipe called with ID: \(recipeId)")
        isLoadingOriginalRecipe = true
        originalRecipeError = nil
        originalRecipe = nil  // Clear any previous recipe
        originalRecipeId = recipeId  // Store the ID for reference
        
        print("📱 State before API call:")
        print("   - isLoadingOriginalRecipe: \(isLoadingOriginalRecipe)")
        print("   - originalRecipe: \(originalRecipe != nil ? "exists" : "nil")")
        print("   - originalRecipeError: \(originalRecipeError ?? "nil")")
        print("   - originalRecipeId: \(originalRecipeId ?? -1)")
        
        // Set global loading state
        globalRecipeHolder.setLoading(true)
        sheetRecipe = nil
        sheetError = nil
        

        
        GetRecipeByIdAction(recipeId: recipeId).call { recipe in
            print("📡 API response received:")
            print("   - Recipe: \(recipe != nil ? "exists" : "nil")")
            if let recipe = recipe {
                print("   - Recipe title: \(recipe.title)")
            }
            
            DispatchQueue.main.async {
                print("🔄 Updating state on main thread...")
                self.isLoadingOriginalRecipe = false
                
                if let recipe = recipe {
                    self.originalRecipe = recipe
                    print("✅ Successfully set originalRecipe")
                    
                    // Set sheet data with the recipe
                    self.sheetData = SheetData(
                        recipe: recipe,
                        error: nil,
                        isLoading: false
                    )
                    
                    // Set alternative variables
                    self.currentSheetRecipe = recipe
                    self.currentSheetError = nil
                    self.currentSheetLoading = false
                    
                    // Set the sheet content directly
                    self.sheetContent = .recipe(recipe)
                    
                    // Set captured variables
                    self.capturedRecipe = recipe
                    self.capturedError = nil
                    self.capturedLoading = false
                    
                    // Set the tuple data directly
                    self.originalRecipeData = (recipe, nil, false)
                    
                    // Set persistent variables
                    self.persistentRecipe = recipe
                    self.persistentError = nil
                    self.persistentLoading = false
                    
                    // Set sheet variables
                    self.sheetRecipe = recipe
                    self.sheetError = nil
                    self.sheetLoading = false
                    

                    
                    print("🔧 After setting sheet variables:")
                    print("   - sheetRecipe: \(self.sheetRecipe != nil ? "exists" : "nil")")
                    print("   - sheetError: \(self.sheetError ?? "nil")")
                    print("   - sheetLoading: \(self.sheetLoading)")
                    
                    // Set global state that survives view recreation
                    self.globalRecipeHolder.setRecipe(recipe)
                    
                    print("🔧 Set global state - recipe: \(recipe.title)")
                } else {
                    self.originalRecipeError = "Failed to fetch original recipe. It may have been deleted or is no longer available."
                    print("❌ Set originalRecipeError")
                    
                    // Set sheet data with the error
                    self.sheetData = SheetData(
                        recipe: nil,
                        error: self.originalRecipeError,
                        isLoading: false
                    )
                    
                    // Set alternative variables
                    self.currentSheetRecipe = nil
                    self.currentSheetError = self.originalRecipeError
                    self.currentSheetLoading = false
                    
                    // Set the sheet content directly
                    if let errorMessage = self.originalRecipeError {
                        self.sheetContent = .error(errorMessage)
                        
                        // Set captured variables
                        self.capturedRecipe = nil
                        self.capturedError = errorMessage
                        self.capturedLoading = false
                        
                        // Set the tuple data directly
                        self.originalRecipeData = (nil, errorMessage, false)
                        
                        // Set persistent variables
                        self.persistentRecipe = nil
                        self.persistentError = errorMessage
                        self.persistentLoading = false
                        
                        // Set sheet variables
                        self.sheetRecipe = nil
                        self.sheetError = errorMessage
                        self.sheetLoading = false
                        
                        // Set global state that survives view recreation
                        self.globalRecipeHolder.setError(errorMessage)
                        
                        print("🔧 Set global state - error: \(errorMessage)")
                        
                    } else {
                        // Fallback error message
                        self.sheetContent = .error("Unknown error occurred")
                        
                        // Set captured variables
                        self.capturedRecipe = nil
                        self.capturedError = "Unknown error occurred"
                        self.capturedLoading = false
                        
                        // Set the tuple data directly
                        self.originalRecipeData = (nil, "Unknown error occurred", false)
                        
                        // Set persistent variables
                        self.persistentRecipe = nil
                        self.persistentError = "Unknown error occurred"
                        self.persistentLoading = false
                        
                        // Set sheet variables
                        self.sheetRecipe = nil
                        self.sheetError = "Unknown error occurred"
                        self.sheetLoading = false
                        
                        // Set global state that survives view recreation
                        self.globalRecipeHolder.setError("Unknown error occurred")
                        
                        print("🔧 Set global state - fallback error")
                    }
                }
                
                print("📱 State after update:")
                print("   - isLoadingOriginalRecipe: \(self.isLoadingOriginalRecipe)")
                print("   - originalRecipe: \(self.originalRecipe != nil ? "exists" : "nil")")
                print("   - originalRecipeError: \(self.originalRecipeError ?? "nil")")
                print("   - originalRecipeId: \(self.originalRecipeId ?? -1)")
                print("   - sheetData: \(self.sheetData != nil ? "exists" : "nil")")
                
                // Show sheet when we have global data
                if self.globalRecipeHolder.currentOriginalRecipe != nil || self.globalRecipeHolder.currentOriginalError != nil {
                    print("✅ Ready to show sheet - setting showingOriginalRecipe to true")
                    
                    print("🔧 Right before showing sheet:")
                    print("   - globalRecipe: \(self.globalRecipeHolder.currentOriginalRecipe != nil ? "exists" : "nil")")
                    print("   - globalError: \(self.globalRecipeHolder.currentOriginalError ?? "nil")")
                    print("   - globalLoading: \(self.globalRecipeHolder.currentOriginalLoading)")
                    
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
