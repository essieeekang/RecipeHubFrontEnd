//
//  RecipeDetailView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 8/1/25.
//

import SwiftUI

struct RecipeDetailView: View {
    @ObservedObject var viewModel: RecipeDetailViewModel
    
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.95, blue: 0.97)
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.recipe.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    Text("by \(viewModel.recipe.authorUsername)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Divider()
                    
                    Text(viewModel.recipe.description)
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(viewModel.recipe.ingredients, id: \.name) { ingredient in
                            Text("- \(ingredient.quantity.clean) \(ingredient.unit) \(ingredient.name)")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(viewModel.recipe.instructions.indices, id: \.self) { index in
                            Text("\(index + 1). \(viewModel.recipe.instructions[index])")
                        }
                    }
                    
                    if viewModel.recipe.favourite {
                        Text("⭐ Favorited")
                            .font(.caption)
                            .padding(.top, 8)
                    }
                    
                    if viewModel.recipe.cooked {
                        Text("✅ You've cooked this!")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding()
            }
            .navigationTitle("Recipe Detail")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#Preview {
    RecipeDetailView(viewModel: .init(recipe: .sample))
}
