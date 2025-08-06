//
//  Recipe.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct RecipeResponse: Decodable {
    let recipes: [Recipe]
}

struct Recipe: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let ingredients: [Ingredient]
    let instructions: [String]
    let isPublic: Bool
    let cooked: Bool
    let favourite: Bool
    let likeCount: Int
    let authorId: Int
    let authorUsername: String
    let originalRecipeId: Int?
    let createdAt: Date
    let updatedAt: Date
    
    // Coding keys for proper encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, title, description, ingredients, instructions, isPublic, cooked, favourite, likeCount, authorId, authorUsername, originalRecipeId, createdAt, updatedAt
    }
    
    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
        instructions = try container.decode([String].self, forKey: .instructions)
        isPublic = try container.decode(Bool.self, forKey: .isPublic)
        cooked = try container.decode(Bool.self, forKey: .cooked)
        favourite = try container.decode(Bool.self, forKey: .favourite)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        authorId = try container.decode(Int.self, forKey: .authorId)
        authorUsername = try container.decode(String.self, forKey: .authorUsername)
        originalRecipeId = try container.decodeIfPresent(Int.self, forKey: .originalRecipeId)
        
        // Handle date decoding
        let dateFormatter = ISO8601DateFormatter()
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        } else {
            createdAt = Date()
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt) {
            updatedAt = dateFormatter.date(from: updatedAtString) ?? Date()
        } else {
            updatedAt = Date()
        }
    }
    
    // Custom initializer for creating new recipes
    init(id: Int, title: String, description: String, ingredients: [Ingredient], instructions: [String], isPublic: Bool, cooked: Bool, favourite: Bool, likeCount: Int, authorId: Int, authorUsername: String, originalRecipeId: Int?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.ingredients = ingredients
        self.instructions = instructions
        self.isPublic = isPublic
        self.cooked = cooked
        self.favourite = favourite
        self.likeCount = likeCount
        self.authorId = authorId
        self.authorUsername = authorUsername
        self.originalRecipeId = originalRecipeId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Custom encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(instructions, forKey: .instructions)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(cooked, forKey: .cooked)
        try container.encode(favourite, forKey: .favourite)
        try container.encode(likeCount, forKey: .likeCount)
        try container.encode(authorId, forKey: .authorId)
        try container.encode(authorUsername, forKey: .authorUsername)
        try container.encodeIfPresent(originalRecipeId, forKey: .originalRecipeId)
        
        // Handle date encoding
        let dateFormatter = ISO8601DateFormatter()
        try container.encode(dateFormatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(dateFormatter.string(from: updatedAt), forKey: .updatedAt)
    }
    
    static let sample =
        Recipe(
            id: 1,
            title: "🍓 Strawberry Shortcake",
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
        )
//        Recipe(
//            id: 2,
//            title: "Matcha Pancakes",
//            description: "Fluffy pancakes with a hint of green tea.",
//            ingredients: [
//                Ingredient(name: "Matcha powder", unit: "tsp", quantity: 2),
//                Ingredient(name: "Milk", unit: "cups", quantity: 1),
//                Ingredient(name: "Eggs", unit: "pieces", quantity: 2)
//            ],
//            instructions: [
//                "Whisk matcha with eggs and milk.",
//                "Add to pancake mix.",
//                "Cook on griddle until bubbles form."
//            ],
//            isPublic: false,
//            cooked: true,
//            favourite: true,
//            likeCount: 89,
//            authorId: 2,
//            authorUsername: "matcha_lover",
//            originalRecipeId: 4,
//            createdAt: ISO8601DateFormatter().date(from: "2025-07-28T19:21:00.000Z") ?? Date(),
//            updatedAt: ISO8601DateFormatter().date(from: "2025-07-28T19:23:00.000Z") ?? Date()
//        )
//    ]
}

struct Ingredient: Codable {
    let name: String
    let unit: String
    let quantity: Double
}
