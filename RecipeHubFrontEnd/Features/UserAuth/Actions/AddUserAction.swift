import Foundation

struct AddUserAction {
    var parameters: AddUserRequest
    
    func call(completion: @escaping (AddUserResponse?) -> Void) {
        guard let url = APIConfig.authRegisterURL() else {
            print("Failed to create URL for user registration")
            return
        }
        
        print("Making request to: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONEncoder().encode(parameters)
            if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("Request body: \(bodyString)")
            }
        } catch {
            print("Encoding error: \(error)")
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
            
            if httpResponse.statusCode != 201 {
                print("User creation failed with status code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            guard let data = data else {
                print("No data returned")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let dataString = String(data: data, encoding: .utf8) {
                print("Raw response data: \(dataString)")
            }

            do {
                let response = try JSONDecoder().decode(AddUserResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response)
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
}
