//
//  Padding.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 28.04.25.
//

import Foundation

enum Padding {
    case tiny, `default`, big, small, middle, medium
    
    var value: CGFloat {
        switch self {
        case .small:
            4
        case .tiny:
            8
        case .medium:
            12
        case .default:
            16
        case .middle:
            20
        case .big:
            32
        }
    }
}
