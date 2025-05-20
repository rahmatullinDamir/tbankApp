//
//  Padding.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 28.04.25.
//

import Foundation

enum Padding {
    case tiny, `default`, big, small
    
    var value: CGFloat {
        switch self {
        case .small:
            4
        case .tiny:
            8
        case .default:
            16
        case .big:
            32
        }
    }
}
