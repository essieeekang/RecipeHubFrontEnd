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
    let imageUrl: String?
    let isPublic: Bool
    let cooked: Bool
    let favourite: Bool
    let likeCount: Int
    let authorId: Int
    let authorUsername: String
    let originalRecipeId: Int?
    let tags: [String]?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, ingredients, instructions, imageUrl, isPublic, cooked, favourite, likeCount, authorId, authorUsername, originalRecipeId, tags, createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
        instructions = try container.decode([String].self, forKey: .instructions)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        isPublic = try container.decode(Bool.self, forKey: .isPublic)
        cooked = try container.decode(Bool.self, forKey: .cooked)
        favourite = try container.decode(Bool.self, forKey: .favourite)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        authorId = try container.decode(Int.self, forKey: .authorId)
        authorUsername = try container.decode(String.self, forKey: .authorUsername)
        originalRecipeId = try container.decodeIfPresent(Int.self, forKey: .originalRecipeId)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        
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
    
    init(id: Int, title: String, description: String, ingredients: [Ingredient], instructions: [String], imageUrl: String?, isPublic: Bool, cooked: Bool, favourite: Bool, likeCount: Int, authorId: Int, authorUsername: String, originalRecipeId: Int?, tags: [String]?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.ingredients = ingredients
        self.instructions = instructions
        self.imageUrl = imageUrl
        self.isPublic = isPublic
        self.cooked = cooked
        self.favourite = favourite
        self.likeCount = likeCount
        self.authorId = authorId
        self.authorUsername = authorUsername
        self.originalRecipeId = originalRecipeId
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(instructions, forKey: .instructions)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(cooked, forKey: .cooked)
        try container.encode(favourite, forKey: .favourite)
        try container.encode(likeCount, forKey: .likeCount)
        try container.encode(authorId, forKey: .authorId)
        try container.encode(authorUsername, forKey: .authorUsername)
        try container.encodeIfPresent(originalRecipeId, forKey: .originalRecipeId)
        try container.encodeIfPresent(tags, forKey: .tags)
        
        // Handle date encoding
        let dateFormatter = ISO8601DateFormatter()
        try container.encode(dateFormatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(dateFormatter.string(from: updatedAt), forKey: .updatedAt)
    }
}

struct Ingredient: Codable {
    let name: String
    let unit: String
    let quantity: Double
}
