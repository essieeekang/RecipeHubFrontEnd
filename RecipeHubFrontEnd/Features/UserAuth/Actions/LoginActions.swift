//
//  LoginActions.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct LoginAction {
    var request: LoginRequest
    
    func call(completion: @escaping (LoginResponse?) -> Void) {
        let scheme: String = "http"
        let host: String = "192.168.0.166"
        let port: Int = 8080
        let path = "/api/auth/login"

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.port = port

        guard let url = components.url else {
            print("Failed to create URL")
            completion(nil)
            return
        }
        
        print("Making request to: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONEncoder().encode(self.request)
            if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("Request body: \(bodyString)")
            }
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
            
            print("Status code: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 {
                print("Login failed with status code: \(httpResponse.statusCode)")
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
                let response = try JSONDecoder().decode(LoginResponse.self, from: data)
                print("Login successful, response: \(response)")
                print("User ID: \(response.user.id), Username: \(response.user.username)")
                DispatchQueue.main.async {
                    completion(response)
                }
            } catch {
                print("Decoding error: \(error)")
                print("Error details: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }

        print("Starting network request...")
        task.resume()
    }
}
