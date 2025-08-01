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
        let scheme: String = "http"
        let host: String = "recipehub-dev-env.eba-6mi9w35s.us-east-2.elasticbeanstalk.com"
        let path = "/api/auth/register"

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path

        guard let url = components.url else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONEncoder().encode(parameters)
        } catch {
            print("Encoding error")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("No data returned")
                return
            }

            do {
                let response = try JSONDecoder().decode(AddUserResponse.self, from: data)
                completion(response)
            } catch {
                print("You have an overlapping username or email. Please try again.")
            }
        }

        task.resume()
    }
}
