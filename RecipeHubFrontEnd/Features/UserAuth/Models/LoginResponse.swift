struct LoginResponse: Decodable {
    let message: String
    let user: User
}
