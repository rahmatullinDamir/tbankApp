import Foundation
import Combine

protocol NotificationsViewModelDelegate: AnyObject {
    func notificationsViewModelDidFinish()
}

protocol NotificationsViewModelling: ViewModel where State == NotificationsViewState, Intent == NotificationsViewIntent {
    var notificationsPublisher: AnyPublisher<[NotificationItem], Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }
    var delegate: NotificationsViewModelDelegate? { get set }
    var notifications: [NotificationItem] { get }
    func loadNotifications()
    func markAsRead(_ ids: [Int64])
    func handleInvitation(tripId: Int64, accept: Bool, notificationId: Int64)
}

class NotificationsViewModel: NotificationsViewModelling {
    @Published private(set) var state: NotificationsViewState = .loading {
        didSet {
            stateDidChange.send()
        }
    }
    
    @Published private(set) var notifications: [NotificationItem] = []
    @Published private(set) var error: String?
    
    var notificationsPublisher: AnyPublisher<[NotificationItem], Never> {
        $notifications.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        $error.eraseToAnyPublisher()
    }
    
    private(set) var stateDidChange = ObservableObjectPublisher()
    weak var delegate: NotificationsViewModelDelegate?
    
    private let notificationService: NotificationServicing
    
    init(notificationService: NotificationServicing = NotificationService()) {
        self.notificationService = notificationService
    }
    
    func trigger(_ intent: NotificationsViewIntent) {
        switch intent {
        case .loadNotifications:
            loadNotifications()
        case .markAsRead(let ids):
            markAsRead(ids)
        case .handleInvitation(let tripId, let accept, let notificationId):
            handleInvitation(tripId: tripId, accept: accept, notificationId: notificationId)
        }
    }
    
    func loadNotifications() {
        Task {
            do {
                state = .loading
                let serverNotifications = try await notificationService.getNotifications(isRead: false)
                let notificationItems = serverNotifications.map { dto in
                    let isInvitation = dto.message.contains("приглашены на участие в поездке")
                    let type: NotificationType = isInvitation ? .invitation : .info
                    
                    return NotificationItem(
                        id: dto.id,
                        type: type,
                        description: dto.message,
                        participants: dto.tripName,
                        amount: nil,
                        date: dto.timestamp,
                        tripId: dto.tripId
                    )
                }
                await MainActor.run {
                    self.notifications = notificationItems
                    self.state = .content
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func markAsRead(_ ids: [Int64]) {
        Task {
            do {
                state = .loading
                try await notificationService.markAsRead(ids)
                loadNotifications()
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func handleInvitation(tripId: Int64, accept: Bool, notificationId: Int64) {
        Task {
            do {
                state = .loading
                if accept {
                    try await notificationService.handleInvitation(tripId: tripId, accept: accept)
                }
                try await notificationService.markAsRead([notificationId])
                loadNotifications()
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }
} 
