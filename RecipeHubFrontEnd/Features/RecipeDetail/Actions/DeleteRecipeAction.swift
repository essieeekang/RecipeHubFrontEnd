import Foundation

struct DeleteRecipeAction {
    let recipeId: Int
    
    func call(completion: @escaping (Bool) -> Void) {
        guard let url = APIConfig.recipeURL(recipeId: String(recipeId)) else {
            print("Failed to create URL for deleting recipe")
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
                
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
                        
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
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
