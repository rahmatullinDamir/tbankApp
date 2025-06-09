import Foundation

protocol NotificationServicing {
    func getNotifications(isRead: Bool) async throws -> [NotificationDto]
    func markAsRead(_ ids: [Int64]) async throws
    func handleInvitation(tripId: Int64, accept: Bool) async throws
}

final class NotificationService: NotificationServicing {
    private let networkService: NetworkServicing
    
    init(networkService: NetworkServicing = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func getNotifications(isRead: Bool) async throws -> [NotificationDto] {
        try await networkService.request(NotificationEndpoints.getNotifications(isRead: isRead))
    }
    
    func markAsRead(_ ids: [Int64]) async throws {
        try await networkService.request(NotificationEndpoints.markAsRead(ids))
    }
    
    func handleInvitation(tripId: Int64, accept: Bool) async throws {
        try await networkService.request(NotificationEndpoints.handleInvitation(tripId: tripId, accept: accept))
    }
} 