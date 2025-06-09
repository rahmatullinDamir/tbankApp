import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let notificationsEnabled = "com.travelerApp.notificationsEnabled"
        static let darkModeEnabled = "com.travelerApp.darkModeEnabled"
    }
    
    private init() {}
    
    var isNotificationsEnabled: Bool {
        get {
            defaults.bool(forKey: Keys.notificationsEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.notificationsEnabled)
        }
    }
    
    var isDarkModeEnabled: Bool {
        get {
            defaults.bool(forKey: Keys.darkModeEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.darkModeEnabled)
        }
    }
    
    func resetSettings() {
        defaults.removeObject(forKey: Keys.notificationsEnabled)
        defaults.removeObject(forKey: Keys.darkModeEnabled)
    }
} 