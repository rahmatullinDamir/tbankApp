import Foundation
import Combine

protocol TripListViewModeling: ViewModel where State == TripListViewState, Intent == TripListViewIntent {
    var currentTrip: TripDto? { get }
    var user: UserDto? { get }
}

protocol TripListViewModelDelegate: AnyObject {
    func tripListViewModelDidSelectTrip(_ trip: TripDto)
    func tripListViewModelDidRequestNewTrip()
    func tripListViewModelDidRequestOpenNotifications()
    func showCreateTrip()
    func showTripDetails(_ trip: TripDto)
}

final class TripListViewModel: TripListViewModeling {
    private let tripService: TripServicing
    private let authService: AuthServicing
    
    @Published private(set) var state: TripListViewState = .loading {
        didSet {
            stateDidChange.send()
        }
    }
    
    @Published private(set) var currentTrip: TripDto?
    @Published private(set) var user: UserDto?
    
    weak var delegate: TripListViewModelDelegate?
    private(set) var stateDidChange = ObservableObjectPublisher()
    
    init(
        authResponse: AuthResponse,
        tripService: TripServicing = TripService(),
        authService: AuthServicing = AuthService()
    ) {
        self.tripService = tripService
        self.authService = authService
        self.user = authResponse.userDto
    }
    
    func trigger(_ intent: TripListViewIntent) {
        switch intent {
        case .onDidLoad:
            Task { await loadTrips() }
        case .createTrip:
            delegate?.showCreateTrip()
        case .tripSelected(let indexPath):
            if case .content(let tripList) = state {
                let trip = tripList[indexPath.item]
                delegate?.showTripDetails(trip)
            }
        case .onReload:
            Task { await loadTrips() }
        case .onAddNewTrip:
            delegate?.tripListViewModelDidRequestNewTrip()
        case .onNotificationsTapped:
            delegate?.tripListViewModelDidRequestOpenNotifications()
        }
    }
    
    private func loadTrips() async {
        state = .loading
        
        do {
            let trips = try await tripService.getAllTripsWithDetails(status: nil)
            if let activeTrip = trips.first(where: { $0.status == .ACTIVE }) {
                currentTrip = activeTrip
            } else {
                currentTrip = trips.first
            }
            await MainActor.run {
                state = .content(trips)
            }
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
            }
        }
    }
} 
