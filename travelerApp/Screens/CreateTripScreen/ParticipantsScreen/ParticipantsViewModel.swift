import Foundation
import Combine

protocol ParticipantsViewModeling: ViewModel where State == ParticipantsViewState, Intent == ParticipantsViewIntent {
    var participants: [UserDto] { get }
    var isNextButtonEnabled: Bool { get }
}

protocol ParticipantsViewModelDelegate: AnyObject {
    func participantsViewModelDidFinishSelectingParticipants(_ trip: TripDto, participants: [String])
}

final class ParticipantsViewModel: ParticipantsViewModeling {
    @Published private(set) var state: ParticipantsViewState = .loading {
        didSet {
            stateDidChange.send()
        }
    }
    
    private(set) var stateDidChange = ObservableObjectPublisher()
    private(set) var participants: [UserDto] = []
    
    private let authService: AuthServicing
    private let tripService: TripServicing
    private let tripData: CreateTripData
    weak var delegate: ParticipantsViewModelDelegate?
    
    var isNextButtonEnabled: Bool {
        !participants.isEmpty
    }
    
    init(
        tripData: CreateTripData, 
        authService: AuthServicing = AuthService(),
        tripService: TripServicing = TripService()
    ) {
        self.tripData = tripData
        self.authService = authService
        self.tripService = tripService
    }
    
    func trigger(_ intent: ParticipantsViewIntent) {
        switch intent {
        case .addParticipant(let phoneNumber):
            Task { await addParticipant(phoneNumber: phoneNumber) }
        case .removeParticipant(let index):
            removeParticipant(at: index)
        case .nextStep:
            Task { await nextButtonTapped() }
        }
    }
    
    private func addParticipant(phoneNumber: String) async {
        let formattedNumber = PhoneNumberFormatter.applyMask(to: phoneNumber)
        guard !participants.contains(where: { $0.phoneNumber == formattedNumber }) else {
            state = .error("Этот участник уже добавлен")
            return
        }
        
        do {
            state = .loading
            let users = try await authService.getUsersByPhoneNumbers([formattedNumber])
            
            guard let user = users.first else {
                state = .error("Пользователь не найден")
                return
            }
            
            participants.append(user)
            state = .participantsUpdated(participants)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    private func removeParticipant(at index: Int) {
        guard index < participants.count else { return }
        participants.remove(at: index)
        state = .participantsUpdated(participants)
    }
    
    private func nextButtonTapped() async {
        let participantPhoneNumbers = participants.map { $0.phoneNumber }
        
        do {
            state = .loading
            
            guard let startDate = tripData.startDate else {
                state = .error("Необходимо указать дату начала поездки")
                return
            }
            
            let endDate = tripData.endDate
            
            let createDto = TripCreateDto(
                name: tripData.name,
                createdDate: Date(),
                startDate: startDate,
                endDate: endDate,
                participants: participantPhoneNumbers,
                totalBudget: Double(tripData.totalBudget ?? 0)
            )
            
            let trip = try await tripService.createTrip(createDto)
            state = .participantsUpdated(participants)
            delegate?.participantsViewModelDidFinishSelectingParticipants(trip, participants: participantPhoneNumbers)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

