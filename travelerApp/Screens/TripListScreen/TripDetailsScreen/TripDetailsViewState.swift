enum TripDetailsViewState {
    case loading
    case content(TripDetailsViewData)
    case error(String)
} 