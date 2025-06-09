//
//  CategoryIcon.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 8.06.25.
//

import Foundation

enum CategoryIcon: String {
    case tickets = "airplane"
    case hotels = "house.fill"
    case food = "fork.knife"
    case entertainment = "star.fill"
    case insurance = "cross.case.fill"
    case other = "plus.circle.fill"
    
    static func from(categoryId: Int64) -> CategoryIcon {
        switch categoryId {
        case 1:
            return .tickets
        case 2:
            return .hotels
        case 3:
            return .food
        case 4:
            return .entertainment
        case 5:
            return .insurance
        default:
            return .other
        }
    }
    
    static func from(categoryName: String) -> CategoryIcon {
            switch categoryName {
            case "Билеты": return .tickets
            case "Отели": return .hotels
            case "Питание": return .food
            case "Развлечения": return .entertainment
            case "Страховка": return .insurance
            default: return .other
            }
        }

    static func from(category: TripCategoryType) -> CategoryIcon {
        switch category {
        case .tickets: return .tickets
        case .hotels: return .hotels
        case .food: return .food
        case .entertainment: return .entertainment
        case .insurance: return .insurance
        case .other: return .other
        }
    }
}
