import Foundation

struct GetUserRecipesAction {
    let userId: Int
    
    func call(completion: @escaping ([Recipe]) -> Void) {
        guard let url = APIConfig.userRecipesURL(userId: String(userId)) else {
            print("Failed to create URL for user recipes")
            completion([])
            return
        }
                
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
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
            
            do {
                let recipes = try JSONDecoder().decode([Recipe].self, from: data)
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
