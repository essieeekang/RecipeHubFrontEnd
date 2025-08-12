import Foundation

struct AddUserRequest: Encodable {
    let username: String
    let email: String
    let password: String
}
