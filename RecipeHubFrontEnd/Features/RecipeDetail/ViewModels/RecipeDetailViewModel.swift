//
//  RecipeDetailView.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 8/1/25.
//

import Foundation

class RecipeDetailViewModel: ObservableObject {
    @Published var recipe: Recipe

    init(recipe: Recipe) {
        self.recipe = recipe
    }
}
