//
//  DeleteRecipeBookAction.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct DeleteRecipeBookAction {
    let bookId: Int
    
    func call(completion: @escaping (Bool) -> Void) {
        guard let url = APIConfig.recipeBookURL(bookId: String(bookId)) else {
            print("Failed to create URL for deleting recipe book")
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        print("Deleting recipe book with ID: \(bookId)")
        
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
            
            print("Delete response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                print("Successfully deleted recipe book with ID: \(bookId)")
                DispatchQueue.main.async {
                    completion(true)
                }
            } else {
                print("Failed to delete recipe book with status code: \(httpResponse.statusCode)")
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