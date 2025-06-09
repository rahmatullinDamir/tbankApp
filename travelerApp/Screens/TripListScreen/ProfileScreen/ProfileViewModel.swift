import Foundation
import Combine

protocol ProfileViewModeling: ViewModel where State == ProfileViewState, Intent == ProfileViewIntent {
    var user: UserDto? { get }
    var isNotificationsEnabled: Bool { get set }
    var isDarkModeEnabled: Bool { get set }
    
    var isNotificationsEnabledPublisher: AnyPublisher<Bool, Never> { get set }
    var isDarkModeEnabledPublisher: AnyPublisher<Bool, Never> { get set }
}

protocol ProfileViewModelDelegate: AnyObject {
    func profileViewModelDidRequestLogout()
}

final class ProfileViewModel: ProfileViewModeling {
    
    @Published private(set) var state: ProfileViewState = .loading {
        didSet {
            stateDidChange.send()
        }
    }
    
    private(set) var stateDidChange = ObservableObjectPublisher()
    weak var delegate: ProfileViewModelDelegate?
    
    private let authService: AuthServicing
    private let userDto: UserDto
    private let userDefaultsManager: UserDefaultsManager
    
    @Published var isNotificationsEnabled: Bool {
        didSet {
            userDefaultsManager.isNotificationsEnabled = isNotificationsEnabled
        }
    }
    
    @Published var isDarkModeEnabled: Bool {
        didSet {
            userDefaultsManager.isDarkModeEnabled = isDarkModeEnabled
        }
    }
    
    private var _isNotificationsEnabledPublisher: AnyPublisher<Bool, Never>?
    private var _isDarkModeEnabledPublisher: AnyPublisher<Bool, Never>?
    
    var isNotificationsEnabledPublisher: AnyPublisher<Bool, Never> {
        get {
            _isNotificationsEnabledPublisher ?? $isNotificationsEnabled.eraseToAnyPublisher()
        }
        set {
            _isNotificationsEnabledPublisher = newValue
        }
    }

    var isDarkModeEnabledPublisher: AnyPublisher<Bool, Never> {
        get {
            _isDarkModeEnabledPublisher ?? $isDarkModeEnabled.eraseToAnyPublisher()
        }
        set {
            _isDarkModeEnabledPublisher = newValue
        }
    }
    
    var user: UserDto? {
        if case .content(let user) = state {
            return user
        }
        return nil
    }
    
    init(authResponse: AuthResponse, 
         authService: AuthServicing = AuthService(),
         userDefaultsManager: UserDefaultsManager = .shared) {
        self.userDto = authResponse.userDto
        self.authService = authService
        self.userDefaultsManager = userDefaultsManager
        self.isNotificationsEnabled = userDefaultsManager.isNotificationsEnabled
        self.isDarkModeEnabled = userDefaultsManager.isDarkModeEnabled
        loadProfile()
    }
    
    private func loadProfile() {
        state = .content(userDto)
    }
    
    func trigger(_ intent: ProfileViewIntent) {
        switch intent {
        case .onDidLoad:
            loadProfile()
            
        case .onToggleNotifications(let enabled):
            isNotificationsEnabled = enabled
            
        case .onToggleDarkMode(let enabled):
            isDarkModeEnabled = enabled
            
        case .onLogout:
            userDefaultsManager.resetSettings()
            authService.logout()
            delegate?.profileViewModelDidRequestLogout()
        }
    }
} 
