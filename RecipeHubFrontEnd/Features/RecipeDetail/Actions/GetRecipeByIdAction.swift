import Foundation

struct GetRecipeByIdAction {
    let recipeId: Int
    
    func call(completion: @escaping (Recipe?) -> Void) {
        guard let url = URL(string: "http://192.168.0.166:8080/api/recipes/\(recipeId)") else {
            print("Invalid URL for fetching recipe by ID")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("Fetching recipe with ID: \(recipeId)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error fetching recipe by ID: \(error)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Get recipe by ID response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    if let data = data {
                        do {
                            let recipe = try JSONDecoder().decode(Recipe.self, from: data)
                            print("Successfully fetched recipe: \(recipe.title)")
                            completion(recipe)
                        } catch {
                            print("Failed to decode recipe response: \(error)")
                            completion(nil)
                        }
                    } else {
                        print("No data received for recipe")
                        completion(nil)
                    }
                } else {
                    print("Server error fetching recipe by ID: \(httpResponse.statusCode)")
                    if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        print("Error message: \(errorMessage)")
                    }
                    completion(nil)
                }
            } else {
                print("Invalid response type")
                completion(nil)
            }
        }.resume()
    }
} 