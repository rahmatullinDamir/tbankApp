import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    
    private let accessTokenKey = "com.travelerApp.accessToken"
    private let refreshTokenKey = "com.travelerApp.refreshToken"
    private let phoneNumberKey = "com.travelerApp.phoneNumber"
    
    private init() {}
    
    func saveTokens(accessToken: String, refreshToken: String) {
        save(accessToken, for: accessTokenKey)
        save(refreshToken, for: refreshTokenKey)
    }
    
    func getAccessToken() -> String? {
        return get(for: accessTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return get(for: refreshTokenKey)
    }
    
    func removeTokens() {
        delete(for: accessTokenKey)
        delete(for: refreshTokenKey)
    }
    
    func savePhoneNumber(_ phoneNumber: String) {
        save(phoneNumber, for: phoneNumberKey)
    }
    
    func getPhoneNumber() -> String? {
        return get(for: phoneNumberKey)
    }
    
    func removePhoneNumber() {
        delete(for: phoneNumberKey)
    }
    
    private func save(_ value: String, for key: String) {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Error saving to Keychain: \(status)")
            return
        }
    }
    
    private func get(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func delete(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
} 
