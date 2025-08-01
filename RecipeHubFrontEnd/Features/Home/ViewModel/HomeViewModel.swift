//
//  HomeViewModel.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    // Sample data for demonstration purposes
    @Published var recipes: [Recipe] = [
        Recipe(
            id: 1,
            title: "Strawberry Shortcake",
            description: "A sweet and fruity dessert.",
            ingredients: [
                Ingredient(name: "Strawberries", unit: "cups", quantity: 2),
                Ingredient(name: "Flour", unit: "cups", quantity: 1.5),
                Ingredient(name: "Sugar", unit: "tbsp", quantity: 4)
            ],
            instructions: [
                "Mix ingredients.",
                "Bake at 350°F for 25 minutes.",
                "Top with strawberries."
            ],
            isPublic: true,
            cooked: false,
            favourite: true,
            likeCount: 128,
            authorId: 1,
            authorUsername: "bakerella",
            originalRecipeId: 3,
            createdAt: ISO8601DateFormatter().date(from: "2025-07-28T19:21:00.000Z") ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: "2025-07-28T19:23:00.000Z") ?? Date()
        ),
        Recipe(
            id: 2,
            title: "Matcha Pancakes",
            description: "Fluffy pancakes with a hint of green tea.",
            ingredients: [
                Ingredient(name: "Matcha powder", unit: "tsp", quantity: 2),
                Ingredient(name: "Milk", unit: "cups", quantity: 1),
                Ingredient(name: "Eggs", unit: "pieces", quantity: 2)
            ],
            instructions: [
                "Whisk matcha with eggs and milk.",
                "Add to pancake mix.",
                "Cook on griddle until bubbles form."
            ],
            isPublic: false,
            cooked: true,
            favourite: true,
            likeCount: 89,
            authorId: 2,
            authorUsername: "matcha_lover",
            originalRecipeId: 4,
            createdAt: ISO8601DateFormatter().date(from: "2025-07-28T19:21:00.000Z") ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: "2025-07-28T19:23:00.000Z") ?? Date()
        )
    ]
}
