//
//  DeleteRecipeAction.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct DeleteRecipeAction {
    let recipeId: Int
    
    func call(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://192.168.0.166:8080/api/recipes/\(recipeId)") else {
            print("Failed to create URL for deleting recipe")
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        print("Deleting recipe with ID: \(recipeId)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            print("Delete recipe response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                print("Successfully deleted recipe with ID: \(recipeId)")
                DispatchQueue.main.async {
                    completion(true)
                }
            } else {
                print("Failed to delete recipe with status code: \(httpResponse.statusCode)")
                if let data = data, let errorString = String(data: data, encoding: .utf8) {
                    print("Error response: \(errorString)")
                }
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
        
        task.resume()
    }
} 
