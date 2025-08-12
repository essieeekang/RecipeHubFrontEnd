//
//  GetUserRecipesAction.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct GetUserRecipesAction {
    let userId: Int
    
    func call(completion: @escaping ([Recipe]) -> Void) {
        guard let url = URL(string: "http://192.168.0.166:8080/api/users/\(userId)/recipes") else {
            print("Failed to create URL for user recipes")
            completion([])
            return
        }
        
        print("Making request to: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Starting network request for user recipes...")
        
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
                print("Failed to fetch recipes with status code: \(httpResponse.statusCode)")
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
                print("Successfully decoded \(recipes.count) recipes")
                DispatchQueue.main.async {
                    completion(recipes)
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
        
        task.resume()
    }
} 
