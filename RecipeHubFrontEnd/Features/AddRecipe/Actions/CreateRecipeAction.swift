//
//  CreateRecipeAction.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct CreateRecipeRequest: Codable {
    let title: String
    let description: String
    let ingredients: [Ingredient]
    let instructions: [String]
    let isPublic: Bool
    let cooked: Bool
    let favourite: Bool
    let authorId: Int
    let originalRecipeId: Int?
}

struct CreateRecipeAction {
    let parameters: CreateRecipeRequest
    
    func call(completion: @escaping (Recipe?) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8080/api/recipes") else {
            print("Failed to create URL for creating recipe")
            completion(nil)
            return
        }
        
        print("Making request to: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(parameters)
            request.httpBody = jsonData
            
            if let bodyString = String(data: jsonData, encoding: .utf8) {
                print("Request body: \(bodyString)")
            }
        } catch {
            print("Encoding error: \(error)")
            completion(nil)
            return
        }
        
        print("Starting network request for creating recipe...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 201 && httpResponse.statusCode != 200 {
                print("Failed to create recipe with status code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if let dataString = String(data: data, encoding: .utf8) {
                print("Raw response data: \(dataString)")
            }
            
            do {
                let recipe = try JSONDecoder().decode(Recipe.self, from: data)
                print("Successfully created recipe with ID: \(recipe.id)")
                print("Recipe details: title=\(recipe.title), originalRecipeId=\(recipe.originalRecipeId?.description ?? "nil")")
                DispatchQueue.main.async {
                    completion(recipe)
                }
            } catch {
                print("Decoding error: \(error)")
                print("Error details: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Missing key: \(key.stringValue), context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: expected \(type), context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value not found: expected \(type), context: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
} 