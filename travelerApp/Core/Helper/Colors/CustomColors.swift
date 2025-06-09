//
//  CustomColors.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 29.04.25.
//

enum CustomColors {
    case yellow, grey, black, blue, lightBlue, lightTextSecondary
    
    var value: String {
        switch self {
        case .yellow:
            return "FFDD2D"
        case .grey:
            return "001024"
        case .black:
            return "333333"
        case .blue:
            return "428BF9"
        case .lightBlue:
            return "36AFFF"
        case .lightTextSecondary:
            return "9299A2"
        }
    }
}
