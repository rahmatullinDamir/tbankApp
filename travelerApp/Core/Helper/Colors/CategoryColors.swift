//
//  CategoryColors.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 8.06.25.
//

enum CategoryColors: String {
    case tickets = "Билеты"
    case hotels = "Отели"
    case food = "Питание"
    case entertainment = "Развлечения"
    case insurance = "Страховка"

    var color: String {
        switch self {
        case .tickets:
            return "#4A90E2"
        case .hotels:
            return "#50E3C2"
        case .food:
            return "#F5A623"
        case .entertainment:
            return "#7ED321"
        case .insurance:
            return "#9013FE"
        }
    }
}

extension CategoryColors {
    static func from(string: String) -> CategoryColors? {
        return CategoryColors(rawValue: string)
    }

    static func color(from string: String) -> String {
        if let category = CategoryColors(rawValue: string) {
            return category.color
        } else {
            return "#B8E986" 
        }
    }
}
