//
//  LoginResponse.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

struct LoginResponse: Decodable {
    let message: String
    let user: User
}
