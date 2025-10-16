//
//  ButtonState.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 18/7/25.
//

import Foundation

enum ButtonState: Equatable {
    case loading
    case normal
    case hide

    var opacity: CGFloat {
        switch self {
        case .loading, .normal:
            1
        case .hide:
            0
        }
    }
}
