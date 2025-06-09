import Foundation

enum ProfileViewIntent {
    case onDidLoad
    case onToggleNotifications(enabled: Bool)
    case onToggleDarkMode(enabled: Bool)
    case onLogout
} 
