//
//  User.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct User: Codable {
    let id: Int
    let username: String
    let email: String
    let createdAt: String
    let updatedAt: String?
    
    var displayName: String {
        return username
    }
}
