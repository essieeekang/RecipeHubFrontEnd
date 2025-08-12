//
//  RecipeBook.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct RecipeBook: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let isPublic: Bool
    let userId: Int
    let recipeIds: [Int]
    
    // Computed properties
    var displayName: String {
        return name
    }
    
    var isPrivate: Bool {
        return !isPublic
    }
    
    var recipeCount: Int {
        return recipeIds.count
    }
    
    // Sample data for testing
    static let sample = RecipeBook(
        id: 1,
        name: "🍰 Dessert Collection",
        description: "My favorite sweet treats and desserts",
        isPublic: true,
        userId: 1,
        recipeIds: [1, 2, 3]
    )
    
    static let sampleBooks = [
        RecipeBook(
            id: 1,
            name: "🍰 Dessert Collection",
            description: "My favorite sweet treats and desserts",
            isPublic: true,
            userId: 1,
            recipeIds: [1, 2, 3]
        ),
        RecipeBook(
            id: 2,
            name: "🥗 Healthy Meals",
            description: "Nutritious and delicious healthy recipes",
            isPublic: false,
            userId: 1,
            recipeIds: [4, 5]
        ),
        RecipeBook(
            id: 3,
            name: "🍕 Italian Favorites",
            description: "Authentic Italian recipes from my grandmother",
            isPublic: true,
            userId: 1,
            recipeIds: [6, 7, 8, 9, 10]
        )
    ]
} 
