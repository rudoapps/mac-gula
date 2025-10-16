//
//  FieldContainerStyle.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 2/9/25.
//

import SwiftUI

class FieldContainerStyle {
    var titleFont: Font
    var subtitleFont: Font
    var messageFont: Font

    var titleColor: Color
    var subtitleColor: Color
    var errorColor: Color
    var focusBorderColor: Color
    var defaultBorderColor: Color
    var backgroundColor: Color

    var padding: CGFloat
    var borderWidth: CGFloat
    var maxHeight: CGFloat?

    var roundedCorner: RoundedCorner

    init(titleFont: Font,
         subtitleFont: Font,
         messageFont: Font,
         titleColor: Color,
         subtitleColor: Color,
         errorColor: Color,
         focusColor: Color,
         defaultBorderColor: Color,
         backgroundColor: Color,
         padding: CGFloat,
         borderWidth: CGFloat,
         maxHeight: CGFloat? = nil,
         roundedCorner: RoundedCorner) {
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
        self.messageFont = messageFont
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.errorColor = errorColor
        self.focusBorderColor = focusColor
        self.defaultBorderColor = defaultBorderColor
        self.backgroundColor = backgroundColor
        self.padding = padding
        self.borderWidth = borderWidth
        self.maxHeight = maxHeight
        self.roundedCorner = roundedCorner
    }

    static var defaultStyle = FieldContainerStyle(
        titleFont: .system(size: 14),
        subtitleFont: .system(size: 12),
        messageFont: .system(size: 12),
        titleColor: .black,
        subtitleColor: .gray,
        errorColor: .red,
        focusColor: .black,
        defaultBorderColor: {
            #if canImport(UIKit)
            return Color(.systemGray5)
            #else
            return Color(NSColor.systemGray)
            #endif
        }(),
        backgroundColor: .white,
        padding: 12,
        borderWidth: 1,
        maxHeight: 48,
        roundedCorner: .standard
    )

    static var noteStyle = FieldContainerStyle(
        titleFont: .system(size: 14),
        subtitleFont: .system(size: 12),
        messageFont: .system(size: 12),
        titleColor: .black,
        subtitleColor: .gray,
        errorColor: .red,
        focusColor: .black,
        defaultBorderColor: {
            #if canImport(UIKit)
            return Color(.systemGray5)
            #else
            return Color(NSColor.systemGray)
            #endif
        }(),
        backgroundColor: .white,
        padding: 12,
        borderWidth: 1,
        roundedCorner: .standard
    )
}
