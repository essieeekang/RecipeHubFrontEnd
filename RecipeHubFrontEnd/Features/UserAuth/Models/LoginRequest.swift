//
//  LoginRequest.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct LoginRequest: Encodable {
    let username: String
    let password: String
}
