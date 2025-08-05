//
//  RecipeBookCardView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import SwiftUI

struct RecipeBookCardView: View {
    let book: RecipeBook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name and privacy indicator
            HStack {
                Text(book.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                // Privacy indicator
                HStack(spacing: 4) {
                    Image(systemName: book.isPublic ? "globe" : "lock")
                        .font(.caption)
                        .foregroundColor(book.isPublic ? .green : .orange)
                    
                    Text(book.isPublic ? "Public" : "Private")
                        .font(.caption)
                        .foregroundColor(book.isPublic ? .green : .orange)
                }
            }
            
            // Description
            Text(book.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            // Recipe count and author info
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.caption)
                        .foregroundColor(.purple)
                    
                    Text("\(book.recipeCount) recipe\(book.recipeCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                Text("by \(book.authorUsername)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Last updated info
            HStack {
                Text("Updated \(formatDate(book.updatedAt))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Preview of recipes (if any)
                if !book.recipes.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(book.recipes.prefix(3), id: \.id) { recipe in
                            Circle()
                                .fill(Color.purple.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                        
                        if book.recipes.count > 3 {
                            Text("+\(book.recipes.count - 3)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    RecipeBookCardView(book: RecipeBook.sample)
        .padding()
} 