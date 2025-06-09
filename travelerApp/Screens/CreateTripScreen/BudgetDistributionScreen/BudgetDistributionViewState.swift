//
//  BudgetDistributionViewState.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 7.06.25.
//

enum BudgetDistributionViewState {
    case loading
    case content(CreateTripData)
    case error(String)
}
