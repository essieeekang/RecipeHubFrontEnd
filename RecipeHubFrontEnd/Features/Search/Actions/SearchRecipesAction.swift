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
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
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
            
            do {
                let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                let searchResponse = SearchResponse(authorId: nil, recipes: recipes, recipeBooks: [], totalRecipes: recipes.count, totalRecipeBooks: 0)
                DispatchQueue.main.async {
                    completion(searchResponse)
                }
            } catch {
                print("Failed to decode as array, trying wrapped response: \(error)")
                
                do {
                    let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
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
