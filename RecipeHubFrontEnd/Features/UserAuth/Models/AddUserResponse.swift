//
//  AddUserResponse.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct AddUserResponse: Identifiable, Decodable {
    let id: Int
    let username: String
    let email: String
    let password: String
    let createdAt: String
}
