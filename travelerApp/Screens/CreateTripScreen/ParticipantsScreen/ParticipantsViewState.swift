//
//  ParticipantsViewState.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 7.06.25.
//

enum ParticipantsViewState {
    case loading
    case participantsUpdated([UserDto])
    case error(String)
}
