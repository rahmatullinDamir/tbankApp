enum NotificationsViewIntent {
    case loadNotifications
    case markAsRead([Int64])
    case handleInvitation(tripId: Int64, accept: Bool, notificationId: Int64)
} 