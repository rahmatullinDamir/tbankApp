import Foundation

enum CreateTripViewState {
    case loading
    case content(CreateTripData)
    case error(String)
} 
