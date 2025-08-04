//
//  RecipeCardView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//


import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    Text("by \(recipe.authorUsername)")
                        .font(.caption)
                        .foregroundColor(.purple)
                    
                    Spacer()
                    
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
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
