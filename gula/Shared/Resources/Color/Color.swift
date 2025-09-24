//
//  Color.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 21/7/25.
//

import SwiftUI

extension Color {
    enum HexadecimalCodeColor: String {
        case whiteBone = "#F9F9F9"
        case blueCloud = "#CAE2F0"
    }

    static func hex(_ hex: HexadecimalCodeColor) -> Color {
        return Color(hex: hex.rawValue)
    }
}
