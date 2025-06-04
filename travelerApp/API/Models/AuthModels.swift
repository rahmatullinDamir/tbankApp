import Foundation

struct AuthResponse: Codable {
    let userDto: UserDto
    let jwtTokenPairDto: JwtTokenPairDto
}

struct LoginDto: Codable {
    let phoneNumber: String
    let password: String
}

struct RegistrationFormDto: Codable {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let password: String
}

struct JwtTokenPairDto: Codable {
    let accessToken: String
    let refreshToken: String
}

struct UserDto: Codable {
    let id: Int64
    let firstName: String
    let lastName: String
    let phoneNumber: String
}
