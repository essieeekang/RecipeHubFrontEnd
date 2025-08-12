//
//  UpdateUserAction.swift
//  RecipeHubFrontEnd
//
//  Created by Esther Kang on 7/31/25.
//

import Foundation

struct UpdateUserRequest: Codable {
    let currentPassword: String?
    let username: String?
    let email: String?
    let newPassword: String?
}

struct UpdateUserAction {
    let userId: Int
    let parameters: UpdateUserRequest
    
    func call(completion: @escaping (User?) -> Void) {
        guard let url = APIConfig.userURL(userId: String(userId)) else {
            print("Failed to create URL for updating user")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(parameters)
            if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("Update user request body: \(bodyString)")
            }
        } catch {
            print("Encoding error: \(error)")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        print("Updating user with ID: \(userId)")
        
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
            
            print("Update user response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                print("Failed to update user with status code: \(httpResponse.statusCode)")
                if let data = data, let errorString = String(data: data, encoding: .utf8) {
                    print("Error response: \(errorString)")
                }
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
            
            if let dataString = String(data: data, encoding: .utf8) {
                print("Raw update user response data: \(dataString)")
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                print("Successfully updated user with ID: \(user.id)")
                print("Updated user details: username=\(user.username), email=\(user.email)")
                DispatchQueue.main.async {
                    completion(user)
                }
            } catch {
                print("Decoding error: \(error)")
                print("Error details: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Missing key: \(key.stringValue), context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: expected \(type), context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value not found: expected \(type), context: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
} 