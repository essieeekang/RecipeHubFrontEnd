//
//  AddUserAction.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct AddUserAction {
    var parameters: AddUserRequest
    func call(completion: @escaping (AddUserResponse) -> Void) {
        let scheme: String = "https"
        let host: String = "back-end-recipe-hub.onrender.com"
//        let scheme: String = "http"
//        let host: String = "127.0.0.1"
//        let port: Int = 80
        let path = "/api/auth/register"

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
//        components.port = port

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
                if httpResponse.statusCode != 201 {
                    print("User creation failed with status code: \(httpResponse.statusCode)")
                    return
                } else {
                    print("User creation successful")
                }
            }

            guard let data = data else {
                print("No data returned")
                return
            }

            do {
                let response = try JSONDecoder().decode(AddUserResponse.self, from: data)
                print("User creation successful, response: \(response)")
                completion(response)
            } catch {
                print("Decoding error: \(error)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Raw response data: \(dataString)")
                }
            }
        }

        print("Starting network request...")
        task.resume()
    }
}
