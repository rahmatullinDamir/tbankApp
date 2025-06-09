//
//  BudgetDistributionViewIntent.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 7.06.25.
//

import Foundation

enum BudgetDistributionViewIntent {
    case onDidLoad
    case toggleCategory(String)
    case updatePercentage(category: String, value: Double)
    case createTrip
}
