//
//  SearchRecipesAction.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct SearchRecipesAction {
    let searchTerm: String
    let searchType: SearchType
    
    func call(completion: @escaping (SearchResponse) -> Void) {
        guard let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = APIConfig.recipeSearchURL(searchType: searchType.endpoint, searchTerm: encodedSearchTerm) else {
            print("Failed to create URL for recipe search")
            let emptyResponse = SearchResponse(authorId: nil, recipes: [], recipeBooks: [], totalRecipes: 0, totalRecipeBooks: 0)
            completion(emptyResponse)
            return
        }
        
        print("Making search request to: \(url)")
        print("Search type: \(searchType.rawValue), endpoint: \(searchType.endpoint)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Starting network request for recipe search...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async {
                    let emptyResponse = SearchResponse(authorId: nil, recipes: [], recipeBooks: [], totalRecipes: 0, totalRecipeBooks: 0)
                    completion(emptyResponse)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                DispatchQueue.main.async {
                    let emptyResponse = SearchResponse(authorId: nil, recipes: [], recipeBooks: [], totalRecipes: 0, totalRecipeBooks: 0)
                    completion(emptyResponse)
                }
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                print("Failed to search recipes with status code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    let emptyResponse = SearchResponse(authorId: nil, recipes: [], recipeBooks: [], totalRecipes: 0, totalRecipeBooks: 0)
                    completion(emptyResponse)
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    let emptyResponse = SearchResponse(authorId: nil, recipes: [], recipeBooks: [], totalRecipes: 0, totalRecipeBooks: 0)
                    completion(emptyResponse)
                }
                return
            }
            
            if let dataString = String(data: data, encoding: .utf8) {
                print("Raw response data: \(dataString)")
                print("Response length: \(dataString.count) characters")
                
                // Try to parse as JSON to see the structure
                if let jsonData = dataString.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: jsonData),
                   let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let prettyString = String(data: prettyData, encoding: .utf8) {
                    print("Formatted JSON response:")
                    print(prettyString)
                }
            }
            
            do {
                // Try to decode as an array first (direct response)
                let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                print("Successfully decoded \(recipes.count) search results (direct array)")
                let searchResponse = SearchResponse(authorId: nil, recipes: recipes, recipeBooks: [], totalRecipes: recipes.count, totalRecipeBooks: 0)
                DispatchQueue.main.async {
                    completion(searchResponse)
                }
            } catch {
                print("Failed to decode as array, trying wrapped response: \(error)")
                
                // Try to decode as a wrapped response
                do {
                    let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                    print("Successfully decoded \(searchResponse.recipeResults.count) search results (wrapped response)")
                    print("Response details: authorId=\(searchResponse.authorId ?? -1), totalRecipes=\(searchResponse.totalRecipes ?? 0)")
                    DispatchQueue.main.async {
                        completion(searchResponse)
                    }
                } catch {
                    print("Failed to decode as wrapped response: \(error)")
                    print("Error details: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        let emptyResponse = SearchResponse(authorId: nil, recipes: [], recipeBooks: [], totalRecipes: 0, totalRecipeBooks: 0)
                        completion(emptyResponse)
                    }
                }
            }
        }
        
        task.resume()
    }
} 
