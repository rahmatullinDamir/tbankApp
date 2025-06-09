//
//  FontFamilies.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 28.04.25.
//

enum FontFamilies {
    case robotoRegular
    case robotoMedium
    case robotoBold
    
    var value: String {
        switch self {
        case .robotoRegular:
            "Roboto-Regular"
        case .robotoMedium:
            "Roboto-Medium"
        case .robotoBold:
            "Roboto-Bold"
        }
    }
}
