import Foundation
import KeychainAccess

final class KeychainManager {
    static let shared = KeychainManager()
    private let keychain = Keychain(service: "com.travelerapp")
    
    private init() {}
    
    private enum Keys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
    }
    
    func saveTokens(accessToken: String, refreshToken: String) {
        do {
            try keychain.set(accessToken, key: Keys.accessToken)
            try keychain.set(refreshToken, key: Keys.refreshToken)
        } catch {
            print("Error saving tokens: \(error)")
        }
    }
    
    func getAccessToken() -> String? {
        do {
            return try keychain.get(Keys.accessToken)
        } catch {
            print("Error getting access token: \(error)")
            return nil
        }
    }
    
    func getRefreshToken() -> String? {
        do {
            return try keychain.get(Keys.refreshToken)
        } catch {
            print("Error getting refresh token: \(error)")
            return nil
        }
    }
    
    func removeTokens() {
        do {
            try keychain.remove(Keys.accessToken)
            try keychain.remove(Keys.refreshToken)
        } catch {
            print("Error removing tokens: \(error)")
        }
    }
} 