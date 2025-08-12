import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    @State private var showingForkSheet = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageUrl = recipe.imageUrl, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .cornerRadius(12)
            }
            
            HStack {
                Text(recipe.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                if let currentUserId = authViewModel.getCurrentUserId(), currentUserId != recipe.authorId {
                    Button(action: {
                        showingForkSheet = true
                    }) {
                        Image(systemName: "arrow.triangle.branch")
                            .foregroundColor(.purple)
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Text(recipe.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack(spacing: 4) {
                Image(systemName: "doc.text")
                    .font(.caption)
                    .foregroundColor(.purple)
                
                Text("\(recipe.ingredients.count) ingredient\(recipe.ingredients.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("by \(recipe.authorUsername)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let originalRecipeId = recipe.originalRecipeId {
                        Text("Forked from recipe #\(originalRecipeId)")
                            .font(.caption2)
                            .foregroundColor(.purple)
                    }
                }
            }
            
            // Recipe Status Indicators
            HStack(spacing: 8) {
                if recipe.favourite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                
                if recipe.cooked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
                
                if recipe.originalRecipeId != nil {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.triangle.branch")
                            .foregroundColor(.purple)
                            .font(.caption)
                        Text("Forked")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                }
                
                Spacer()
                
                Text("\(recipe.likeCount) like\(recipe.likeCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .sheet(isPresented: $showingForkSheet) {
            AddRecipeView(recipeToFork: recipe)
        }
    }
}
