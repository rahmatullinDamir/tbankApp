//
//  Padding.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 28.04.25.
//

import Foundation

enum Padding {
    case tiny, `default`, big
    
    var value: CGFloat {
        switch self {
        case .tiny:
            10
        case .default:
            16
        case .big:
            32
        }
    }
}
