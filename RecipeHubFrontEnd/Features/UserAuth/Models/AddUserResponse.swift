import Foundation

struct AddUserResponse: Identifiable, Decodable {
    let id: Int
    let username: String
    let email: String
    let createdAt: String
}
