import Foundation

struct UpdateRecipeRequest: Codable {
    let authorId: Int
    let title: String?
    let description: String?
    let ingredients: [Ingredient]?
    let instructions: [String]?
    let imageUrl: String?
    let isPublic: Bool?
    let cooked: Bool?
    let favourite: Bool?
    let likeCount: Int?

}

struct UpdateRecipeAction {
    let recipeId: Int
    let parameters: UpdateRecipeRequest
    
    func call(completion: @escaping (Recipe?) -> Void) {
        guard let url = APIConfig.recipeURL(recipeId: String(recipeId)) else {
            print("Invalid URL for updating recipe")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(parameters)
            request.httpBody = jsonData
            print("Update recipe request body: \(String(data: jsonData, encoding: .utf8) ?? "")")
        } catch {
            print("Failed to encode update recipe request: \(error)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error updating recipe: \(error)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Update recipe response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    if let data = data {
                        do {
                            let updatedRecipe = try JSONDecoder().decode(Recipe.self, from: data)
                            print("Successfully updated recipe: \(updatedRecipe.title)")
                            completion(updatedRecipe)
                        } catch {
                            print("Failed to decode updated recipe response: \(error)")
                            completion(nil)
                        }
                    } else {
                        print("No data received for updated recipe")
                        completion(nil)
                    }
                } else {
                    print("Server error updating recipe: \(httpResponse.statusCode)")
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