import SwiftUI

struct SearchRecipeBookCardView: View {
    let recipeBook: RecipeBook
    
    var body: some View {
        NavigationLink(destination: SearchBookDetailView(recipeBook: recipeBook)) {
            VStack(alignment: .leading, spacing: 12) {
                // Book name and privacy indicator
                HStack {
                    Text(recipeBook.displayName)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Privacy indicator
                    HStack(spacing: 4) {
                        Image(systemName: recipeBook.isPublic ? "globe" : "lock")
                            .font(.caption)
                            .foregroundColor(recipeBook.isPublic ? .green : .orange)
                        
                        Text(recipeBook.isPublic ? "Public" : "Private")
                            .font(.caption)
                            .foregroundColor(recipeBook.isPublic ? .green : .orange)
                    }
                }
                
                // Description
                Text(recipeBook.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Recipe count
                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.caption)
                        .foregroundColor(.purple)
                    
                    Text("\(recipeBook.recipeCount) recipe\(recipeBook.recipeCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Recipe preview dots (if any recipes)
                if !recipeBook.recipeIds.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(0..<min(3, recipeBook.recipeIds.count), id: \.self) { _ in
                            Circle()
                                .fill(Color.purple.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                        
                        if recipeBook.recipeIds.count > 3 {
                            Text("+\(recipeBook.recipeIds.count - 3)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    SearchRecipeBookCardView(recipeBook: RecipeBook.sample)
} 