//
//  UiColorExtension.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 28.04.25.
//

import UIKit

enum CustomColors {
    case yellow, grey, black, blue
    
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
        }
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
