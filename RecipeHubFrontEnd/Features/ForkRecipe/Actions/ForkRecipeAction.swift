//
//  ForkRecipeAction.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct ForkRecipeRequest: Codable {
    let title: String
    let description: String
    let ingredients: [Ingredient]
    let instructions: [String]
    let isPublic: Bool
    let cooked: Bool
    let favourite: Bool
    let authorId: Int
    let originalRecipeId: Int
}

struct ForkRecipeAction {
    let recipeId: Int
    let parameters: ForkRecipeRequest
    
    func call(completion: @escaping (Recipe?) -> Void) {
        guard let url = APIConfig.forkRecipeURL(recipeId: String(recipeId)) else {
            print("Failed to create URL for forking recipe")
            completion(nil)
            return
        }
        
        print("Making fork request to: \(url)")
        
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
        
        print("Starting network request for forking recipe...")
        
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
                print("Failed to fork recipe with status code: \(httpResponse.statusCode)")
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
                let forkedRecipe = try JSONDecoder().decode(Recipe.self, from: data)
                print("Successfully forked recipe with ID: \(forkedRecipe.id)")
                print("Original recipe ID: \(forkedRecipe.originalRecipeId?.description ?? "nil")")
                DispatchQueue.main.async {
                    completion(forkedRecipe)
                }
            } catch {
                print("Decoding error: \(error)")
                print("Error details: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
} 
