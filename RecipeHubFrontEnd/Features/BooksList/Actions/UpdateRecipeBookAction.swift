//
//  UpdateRecipeBookAction.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct UpdateRecipeBookRequest: Codable {
    let name: String?
    let description: String?
    let isPublic: Bool?
    let recipeIds: [Int]?
}

struct UpdateRecipeBookAction {
    let bookId: Int
    let parameters: UpdateRecipeBookRequest
    
    func call(completion: @escaping (RecipeBook?) -> Void) {
        guard let url = URL(string: "http://192.168.0.166:8080/api/recipebooks/\(bookId)") else {
            print("Failed to create URL for updating recipe book")
            completion(nil)
            return
        }
        
        print("Making PUT request to: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
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
        
        print("Starting network request for updating recipe book...")
        
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
            
            if httpResponse.statusCode != 200 {
                print("Failed to update recipe book with status code: \(httpResponse.statusCode)")
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
                print("Successfully updated recipe book with ID: \(recipeBook.id)")
                print("Updated recipe book: \(recipeBook.name) with \(recipeBook.recipeIds.count) recipes")
                DispatchQueue.main.async {
                    completion(recipeBook)
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
