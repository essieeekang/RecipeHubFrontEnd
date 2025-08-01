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
        HStack(spacing: 16) {
            ZStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(recipe.title)
                            .font(.headline)
                        Text(recipe.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
            }
        }
    }
}
