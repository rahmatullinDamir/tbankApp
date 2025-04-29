//
//  FontsConstants.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 28.04.25.
//

import Foundation

enum FontConstants {
    case tiny, `default`, title, header, regular
    
    var value: CGFloat {
        switch self {
        case .tiny:
            12
        case .regular:
            16
        case .default:
            18
        case .title:
            22
        case .header:
            32
        }
    }
}
