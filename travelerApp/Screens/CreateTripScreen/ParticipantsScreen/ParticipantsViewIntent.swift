//
//  ParticipantsViewIntent.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 7.06.25.
//

enum ParticipantsViewIntent {
    case addParticipant(phoneNumber: String)
    case removeParticipant(at: Int)
    case nextStep
}
