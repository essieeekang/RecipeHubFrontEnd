//
//  LoginActions.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct LoginAction {
    var parameters: LoginRequest
    func call(completion: @escaping (LoginResponse) -> Void) {
        let scheme: String = "http"
        let host: String = "192.168.0.166"
        let port: Int = 8080
        let path = "/api/auth/login"

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        components.path = path

        guard let url = components.url else {
            print("Failed to create URL")
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
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("Login failed with status code: \(httpResponse.statusCode)")
                    return
                } else {
                    print("Login successful")
                }
            }

            guard let data = data else {
                print("No data returned")
                return
            }

            do {
                let response = try JSONDecoder().decode(LoginResponse.self, from: data)
                print("Login successful, response: \(response)")
                completion(response)
            } catch {
                print("Decoding error: \(error)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Raw response data: \(dataString)")
                    // If the response is plain text "Login successful", create a response manually
                    if dataString.trimmingCharacters(in: .whitespacesAndNewlines) == "Login successful" {
                        let response = LoginResponse(body: dataString)
                        print("Created response from plain text: \(response)")
                        print("About to call completion handler")
                        completion(response)
                        print("Completion handler called")
                    }
                }
            }
        }

        print("Starting network request...")
        task.resume()
    }
}
