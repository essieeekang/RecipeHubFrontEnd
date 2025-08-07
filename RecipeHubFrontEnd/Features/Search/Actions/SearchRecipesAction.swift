//
//  SearchRecipesAction.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct SearchRecipesAction {
    let searchTerm: String
    
    func call(completion: @escaping ([Recipe]) -> Void) {
        guard let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://127.0.0.1:8080/api/recipes/search?title=\(encodedSearchTerm)") else {
            print("Failed to create URL for recipe search")
            completion([])
            return
        }
        
        print("Making search request to: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Starting network request for recipe search...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                print("Failed to search recipes with status code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            if let dataString = String(data: data, encoding: .utf8) {
                print("Raw response data: \(dataString)")
            }
            
            do {
                let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                print("Successfully decoded \(recipes.count) search results")
                DispatchQueue.main.async {
                    completion(recipes)
                }
            } catch {
                print("Decoding error: \(error)")
                print("Error details: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
        
        task.resume()
    }
} 