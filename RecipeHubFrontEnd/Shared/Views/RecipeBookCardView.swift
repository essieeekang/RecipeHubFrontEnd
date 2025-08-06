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
            // Book name and privacy indicator
            HStack {
                Text(book.displayName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
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
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Recipe count
            HStack(spacing: 4) {
                Image(systemName: "doc.text")
                    .font(.caption)
                    .foregroundColor(.purple)
                
                Text("\(book.recipeCount) recipe\(book.recipeCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Recipe preview dots (if any recipes)
            if !book.recipeIds.isEmpty {
                HStack(spacing: 4) {
                    ForEach(0..<min(3, book.recipeIds.count), id: \.self) { _ in
                        Circle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                    
                    if book.recipeIds.count > 3 {
                        Text("+\(book.recipeIds.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    RecipeBookCardView(book: RecipeBook.sample)
        .padding()
} 