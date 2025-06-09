import Foundation

enum TripListViewState {
    case loading
    case content(TripListDto)
    case error(String)
} 
