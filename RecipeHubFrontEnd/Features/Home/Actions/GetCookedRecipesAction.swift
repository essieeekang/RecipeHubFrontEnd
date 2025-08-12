import Foundation

struct GetCookedRecipesAction {
    let userId: Int
    
    func call(completion: @escaping ([Recipe]) -> Void) {
        guard let url = APIConfig.userCookedRecipesURL(userId: String(userId)) else {
            print("Failed to create URL for cooked recipes")
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
                print("Failed to fetch cooked recipes with status code: \(httpResponse.statusCode)")
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
                print("Error details: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
        
        task.resume()
    }
} 
