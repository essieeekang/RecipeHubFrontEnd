import Foundation

struct ForkRecipeRequest: Codable {
    let title: String
    let description: String
    let ingredients: [Ingredient]
    let instructions: [String]
    let isPublic: Bool
    let cooked: Bool
    let favourite: Bool
    let authorId: Int
    let originalRecipeId: Int
}

struct ForkRecipeAction {
    let recipeId: Int
    let parameters: ForkRecipeRequest
    
    func call(completion: @escaping (Recipe?) -> Void) {
        guard let url = APIConfig.forkRecipeURL(recipeId: String(recipeId)) else {
            print("Failed to create URL for forking recipe")
            completion(nil)
            return
        }
                
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(parameters)
            request.httpBody = jsonData
            
        } catch {
            print("Encoding error: \(error)")
            completion(nil)
            return
        }
                
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
                        
            if httpResponse.statusCode != 201 && httpResponse.statusCode != 200 {
                print("Failed to fork recipe with status code: \(httpResponse.statusCode)")
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
            
            do {
                let forkedRecipe = try JSONDecoder().decode(Recipe.self, from: data)
                DispatchQueue.main.async {
                    completion(forkedRecipe)
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
