//
//  AddRecipeView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI
import PhotosUI

struct AddRecipeView: View {
    @StateObject private var viewModel = AddRecipeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    let onRecipeCreated: ((Recipe) -> Void)?
    let recipeToFork: Recipe? // New parameter for forking
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    init(recipeToFork: Recipe? = nil, onRecipeCreated: ((Recipe) -> Void)? = nil) {
        self.recipeToFork = recipeToFork
        self.onRecipeCreated = onRecipeCreated
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Forking Header (if forking)
                        if viewModel.isForking, let originalRecipe = viewModel.originalRecipe {
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "arrow.triangle.branch")
                                        .foregroundColor(.purple)
                                    Text("Forking Recipe")
                                        .font(.headline)
                                        .foregroundColor(.purple)
                                }
                                
                                VStack(spacing: 4) {
                                    Text("Original Recipe: \(originalRecipe.title)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Text("Originally by: \(originalRecipe.authorUsername)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    if let currentUsername = authViewModel.getCurrentUsername() {
                                        Text("You will be credited as the forker")
                                            .font(.caption)
                                            .foregroundColor(.purple)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Recipe Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recipe Title")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            TextField("Enter recipe title", text: $viewModel.title)
                                .textFieldStyle(RoundedField())
                                .disabled(viewModel.isLoading)
                        }
                        
                        // Recipe Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            TextField("Describe your recipe", text: $viewModel.description, axis: .vertical)
                                .textFieldStyle(RoundedField())
                                .lineLimit(3...6)
                                .disabled(viewModel.isLoading)
                        }
                        
                        // Recipe Image
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recipe Image")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            if let selectedImage = viewModel.selectedImage {
                                VStack(spacing: 8) {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 200)
                                        .clipped()
                                        .cornerRadius(12)
                                    
                                    Button("Remove Image") {
                                        viewModel.removeImage()
                                    }
                                    .foregroundColor(.red)
                                    .font(.caption)
                                }
                            } else {
                                Button(action: viewModel.addImage) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.purple)
                                        Text("Add Recipe Photo")
                                            .font(.subheadline)
                                            .foregroundColor(.purple)
                                        Text("Camera or Library")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 120)
                                    .background(Color.purple.opacity(0.1))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                                    )
                                }
                                .disabled(viewModel.isLoading)
                            }
                        }
                        
                        // Ingredients Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Ingredients")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                
                                Spacer()
                                
                                Button(action: viewModel.addIngredient) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.purple)
                                        .font(.title2)
                                }
                                .disabled(viewModel.isLoading)
                            }
                            
                            ForEach(Array(viewModel.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                                IngredientRowView(
                                    ingredient: $viewModel.ingredients[index],
                                    onRemove: {
                                        viewModel.removeIngredient(at: index)
                                    },
                                    isDisabled: viewModel.isLoading
                                )
                            }
                        }
                        
                        // Instructions Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Instructions")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                
                                Spacer()
                                
                                Button(action: viewModel.addInstruction) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.purple)
                                        .font(.title2)
                                }
                                .disabled(viewModel.isLoading)
                            }
                            
                            ForEach(Array(viewModel.instructions.enumerated()), id: \.offset) { index, instruction in
                                InstructionRowView(
                                    instruction: $viewModel.instructions[index],
                                    stepNumber: index + 1,
                                    onRemove: {
                                        viewModel.removeInstruction(at: index)
                                    },
                                    isDisabled: viewModel.isLoading
                                )
                            }
                        }
                        
                        // Recipe Settings
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Settings")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            VStack(spacing: 12) {
                                Toggle("Make recipe public", isOn: $viewModel.isPublic)
                                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                                    .disabled(viewModel.isLoading)
                                
                                Toggle("Mark as cooked", isOn: $viewModel.cooked)
                                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                                    .disabled(viewModel.isLoading)
                                
                                Toggle("Add to favorites", isOn: $viewModel.favourite)
                                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                                    .disabled(viewModel.isLoading)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Error Message
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Submit Button
                        Button(action: submitRecipe) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(viewModel.submitButtonTitle)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.canSubmit ? Color.purple : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!viewModel.canSubmit)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Recipe Created!", isPresented: $viewModel.isRecipeCreated) {
            Button("OK") {
                if let recipe = viewModel.createdRecipe {
                    onRecipeCreated?(recipe)
                }
                dismiss()
            }
        } message: {
            Text(viewModel.isForking ? "Your forked recipe has been successfully created and saved." : "Your recipe has been successfully created and saved.")
        }
        .onAppear {
            if let recipe = recipeToFork, let currentUserId = authViewModel.getCurrentUserId() {
                viewModel.populateWithRecipe(recipe, currentUserId: currentUserId)
            }
        }
        .photosPicker(isPresented: $viewModel.showingImagePicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        viewModel.selectedImage = image
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingCamera) {
            CameraView { image in
                viewModel.selectedImage = image
            }
        }
        .actionSheet(isPresented: $viewModel.showingImageOptions) {
            ActionSheet(
                title: Text("Add Recipe Photo"),
                message: Text("Choose how you'd like to add a photo"),
                buttons: [
                    .default(Text("Take Photo")) {
                        viewModel.takePhoto()
                    },
                    .default(Text("Choose from Library")) {
                        viewModel.selectFromLibrary()
                    },
                    .cancel()
                ]
            )
        }
    }
    
    private func submitRecipe() {
        guard let currentUser = authViewModel.getCurrentUser() else {
            viewModel.errorMessage = "User not authenticated"
            return
        }
        
        if viewModel.isForking {
            viewModel.forkRecipe(authorId: currentUser.id) { success in
                if success {
                    print("Recipe forked successfully")
                } else {
                    print("Failed to fork recipe")
                }
            }
        } else {
            viewModel.createRecipe(authorId: currentUser.id) { success in
                if success {
                    print("Recipe created successfully")
                } else {
                    print("Failed to create recipe")
                }
            }
        }
    }
}



#Preview {
    AddRecipeView()
        .environmentObject(AuthViewModel())
}
