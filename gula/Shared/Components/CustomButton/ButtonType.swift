//
//  ButtonType.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 18/7/25.
//

import SwiftUI

enum ButtonType {
    case primary
    case secondary
    case tertiary

    var gradientColors: [Color] {
        switch self {
        case .primary:
            [Color.blue, Color.cyan]
        case .secondary:
            [Color.gray, Color.gray.opacity(0.8)]
        case .tertiary:
            [Color.gray, Color.gray.opacity(0.8)]
        }
    }

    var background: Color {
        switch self {
        case .primary:
            Color.blue
        case .secondary:
            Color.gray
        case .tertiary:
            Color.gray
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary:
            Color.white
        case .secondary:
            Color.black
        case .tertiary:
            Color.white
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .primary:
            0
        case .secondary:
            0
        case .tertiary:
            0
        }
    }
}
