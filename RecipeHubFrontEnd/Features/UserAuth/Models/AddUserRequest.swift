//
//  AddUserRequest.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct AddUserRequest: Encodable {
    let username: String
    let email: String
    let password: String
}
