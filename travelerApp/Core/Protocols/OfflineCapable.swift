import Foundation

protocol OfflineCapable {
    func saveOfflineData<T>(_ data: T)
    func getOfflineData<T>() -> T?
    func clearOfflineData()
    func syncWithServer() async throws
}

extension OfflineCapable {
    func handleOfflineOperation<T>(_ operation: () async throws -> T,
                                 fallback: () -> T?) async -> T? {
        do {
            let result = try await operation()
            saveOfflineData(result)
            return result
        } catch {
            if let offlineData = fallback() {
                return offlineData
            }
            return nil
        }
    }
} 