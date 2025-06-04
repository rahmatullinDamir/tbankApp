import Foundation

protocol AuthServicing {
    func login(with credentials: LoginDto) async throws -> AuthResponse
    func register(with form: RegistrationFormDto) async throws -> AuthResponse
    func refreshToken() async throws -> JwtTokenPairDto
    func logout()
}

final class AuthService: AuthServicing {
    private let networkService: NetworkServicing
    private let keychainManager: KeychainManager
    
    init(networkService: NetworkServicing = NetworkService.shared) {
        self.networkService = networkService
        self.keychainManager = .shared
    }
    
    func login(with credentials: LoginDto) async throws -> AuthResponse {
        let endpoint = AuthEndpoints.login(credentials)
        let response: AuthResponse = try await networkService.request(endpoint)
        let tokens = response.jwtTokenPairDto
        keychainManager.saveTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
        return response
    }
    
    func register(with form: RegistrationFormDto) async throws -> AuthResponse {
        let endpoint = AuthEndpoints.register(form)
        let response: AuthResponse = try await networkService.request(endpoint)
        let tokens = response.jwtTokenPairDto
        keychainManager.saveTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
        return response
    }
    
    func refreshToken() async throws -> JwtTokenPairDto {
        let endpoint = AuthEndpoints.refreshToken
        return try await networkService.request(endpoint)
    }
    
    func logout() {
        keychainManager.removeTokens()
    }
}
