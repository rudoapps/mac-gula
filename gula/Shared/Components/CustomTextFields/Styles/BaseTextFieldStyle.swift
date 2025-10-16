//
//  CustomTextFieldStyle.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 2/9/25.
//

import SwiftUI

class BaseTextFieldStyle {
    var font: Font
    var textColor: Color
    var disabledColor: Color

    init(font: Font, textColor: Color, disabledColor: Color) {
        self.font = font
        self.textColor = textColor
        self.disabledColor = disabledColor
    }

    static var defaultStyle: BaseTextFieldStyle = .init(
        font: .system(size: 14, weight: .light),
        textColor: .black,
        disabledColor: {
            #if canImport(UIKit)
            return Color(.systemGray4)
            #else
            return Color(NSColor.systemGray)
            #endif
        }()
    )
}
