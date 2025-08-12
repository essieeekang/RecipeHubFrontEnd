//
//  CreateRecipeBookAction.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct CreateRecipeBookRequest: Codable {
    let name: String
    let description: String
    let isPublic: Bool
    let userId: Int
    let recipeIds: [Int]
}

struct CreateRecipeBookAction {
    let parameters: CreateRecipeBookRequest
    
    func call(completion: @escaping (RecipeBook?) -> Void) {
        guard let url = APIConfig.recipeBooksURL() else {
            print("Failed to create URL for creating recipe book")
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
        
        print("Starting network request for creating recipe book...")
        
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
                print("Failed to create recipe book with status code: \(httpResponse.statusCode)")
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
                let recipeBook = try JSONDecoder().decode(RecipeBook.self, from: data)
                print("Successfully created recipe book with ID: \(recipeBook.id)")
                DispatchQueue.main.async {
                    completion(recipeBook)
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
} 
