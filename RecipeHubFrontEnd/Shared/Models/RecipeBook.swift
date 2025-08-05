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
    let authorId: Int
    let authorUsername: String
    let recipeCount: Int
    let createdAt: Date
    let updatedAt: Date
    let recipes: [Recipe]
    
    // Computed properties
    var displayName: String {
        return name
    }
    
    var isPrivate: Bool {
        return !isPublic
    }
    
    // Coding keys for proper encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, name, description, isPublic, authorId, authorUsername, recipeCount, createdAt, updatedAt, recipes
    }
    
    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        isPublic = try container.decode(Bool.self, forKey: .isPublic)
        authorId = try container.decode(Int.self, forKey: .authorId)
        authorUsername = try container.decode(String.self, forKey: .authorUsername)
        recipeCount = try container.decode(Int.self, forKey: .recipeCount)
        recipes = try container.decode([Recipe].self, forKey: .recipes)
        
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
    
    // Custom initializer for creating new books
    init(id: Int, name: String, description: String, isPublic: Bool, authorId: Int, authorUsername: String, recipeCount: Int, createdAt: Date, updatedAt: Date, recipes: [Recipe]) {
        self.id = id
        self.name = name
        self.description = description
        self.isPublic = isPublic
        self.authorId = authorId
        self.authorUsername = authorUsername
        self.recipeCount = recipeCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.recipes = recipes
    }
    
    // Custom encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(authorId, forKey: .authorId)
        try container.encode(authorUsername, forKey: .authorUsername)
        try container.encode(recipeCount, forKey: .recipeCount)
        try container.encode(recipes, forKey: .recipes)
        
        // Handle date encoding
        let dateFormatter = ISO8601DateFormatter()
        try container.encode(dateFormatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(dateFormatter.string(from: updatedAt), forKey: .updatedAt)
    }
    
    // Sample data for testing
    static let sample = RecipeBook(
        id: 1,
        name: "🍰 Dessert Collection",
        description: "My favorite sweet treats and desserts",
        isPublic: true,
        authorId: 1,
        authorUsername: "bakerella",
        recipeCount: 3,
        createdAt: ISO8601DateFormatter().date(from: "2025-07-28T19:21:00.000Z") ?? Date(),
        updatedAt: ISO8601DateFormatter().date(from: "2025-07-28T19:23:00.000Z") ?? Date(),
        recipes: [Recipe.sample]
    )
    
    static let sampleBooks = [
        RecipeBook(
            id: 1,
            name: "🍰 Dessert Collection",
            description: "My favorite sweet treats and desserts",
            isPublic: true,
            authorId: 1,
            authorUsername: "bakerella",
            recipeCount: 3,
            createdAt: ISO8601DateFormatter().date(from: "2025-07-28T19:21:00.000Z") ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: "2025-07-28T19:23:00.000Z") ?? Date(),
            recipes: [Recipe.sample]
        ),
        RecipeBook(
            id: 2,
            name: "🥗 Healthy Meals",
            description: "Nutritious and delicious healthy recipes",
            isPublic: false,
            authorId: 1,
            authorUsername: "bakerella",
            recipeCount: 2,
            createdAt: ISO8601DateFormatter().date(from: "2025-07-28T19:21:00.000Z") ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: "2025-07-28T19:23:00.000Z") ?? Date(),
            recipes: []
        ),
        RecipeBook(
            id: 3,
            name: "🍕 Italian Favorites",
            description: "Authentic Italian recipes from my grandmother",
            isPublic: true,
            authorId: 1,
            authorUsername: "bakerella",
            recipeCount: 5,
            createdAt: ISO8601DateFormatter().date(from: "2025-07-28T19:21:00.000Z") ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: "2025-07-28T19:23:00.000Z") ?? Date(),
            recipes: []
        )
    ]
} 
