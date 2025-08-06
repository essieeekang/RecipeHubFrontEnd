//
//  GetUserRecipeBooksAction.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct GetUserRecipeBooksAction {
    let userId: Int
    
    func call(completion: @escaping ([RecipeBook]) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8080/api/users/\(userId)/recipe-books") else {
            print("Failed to create URL for user recipe books")
            completion([])
            return
        }
        
        print("Making request to: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Starting network request for user recipe books...")
        
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
                print("Failed to fetch recipe books with status code: \(httpResponse.statusCode)")
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
                let recipeBooks = try JSONDecoder().decode([RecipeBook].self, from: data)
                print("Successfully decoded \(recipeBooks.count) recipe books")
                DispatchQueue.main.async {
                    completion(recipeBooks)
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