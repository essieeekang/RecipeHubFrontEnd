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
    let imageData: Data?
    let imageFileName: String?
}

struct CreateRecipeAction {
    let parameters: CreateRecipeRequest
    
    func call(completion: @escaping (Recipe?) -> Void) {
        guard let url = URL(string: "http://192.168.0.166:8080/api/recipes") else {
            print("Failed to create URL for creating recipe")
            completion(nil)
            return
        }
        
        print("Making request to: \(url)")
        
        // Generate boundary string
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create multipart form data
        var body = Data()
        
        // Function to add text field
        func addFormField(named name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add text fields
        addFormField(named: "title", value: parameters.title)
        addFormField(named: "description", value: parameters.description)
        
        // Convert ingredients to JSON string
        if let ingredientsData = try? JSONEncoder().encode(parameters.ingredients),
           let ingredientsString = String(data: ingredientsData, encoding: .utf8) {
            addFormField(named: "ingredients", value: ingredientsString)
        }
        
        // Convert instructions to JSON string
        if let instructionsData = try? JSONEncoder().encode(parameters.instructions),
           let instructionsString = String(data: instructionsData, encoding: .utf8) {
            addFormField(named: "instructions", value: instructionsString)
        }
        
        addFormField(named: "isPublic", value: parameters.isPublic.description)
        addFormField(named: "cooked", value: parameters.cooked.description)
        addFormField(named: "favourite", value: parameters.favourite.description)
        addFormField(named: "authorId", value: String(parameters.authorId))
        
        if let originalRecipeId = parameters.originalRecipeId {
            addFormField(named: "originalRecipeId", value: String(originalRecipeId))
        }
        
        // Add image file if provided
        if let imageData = parameters.imageData, let fileName = parameters.imageFileName {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Add final boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        print("Starting network request for creating recipe...")
        print("Request body length: \(body.count) bytes")
        
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
                if let data = data, let errorString = String(data: data, encoding: .utf8) {
                    print("Error response: \(errorString)")
                }
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
