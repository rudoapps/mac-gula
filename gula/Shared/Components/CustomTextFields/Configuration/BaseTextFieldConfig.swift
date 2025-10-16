//
//  CustomTextFieldConfig.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 2/9/25.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
typealias KeyboardType = UIKeyboardType
typealias TextCapitalization = TextInputAutocapitalization
#else
// macOS alternatives
enum KeyboardType {
    case `default`
    case emailAddress
    case numberPad
    case phonePad
    case URL
    case decimalPad
}

enum TextCapitalization {
    case never
    case words
    case sentences
    case characters
}
#endif

class BaseTextFieldConfig {
    var keyboardType: KeyboardType
    var textInputAutocapitalization: TextCapitalization
    var maxLength: Int
    var submitLabel: SubmitLabel
    var lineLimitCount: Int
    var haslineLimitReservedSpace: Bool
    var axisFont: Axis
    var alignment: Alignment

    init(keyboardType: KeyboardType,
         textInputAutocapitalization: TextCapitalization,
         maxLength: Int,
         submitLabel: SubmitLabel,
         lineLimitCount: Int,
         haslineLimitReservedSpace: Bool = false,
         axisFont: Axis = .horizontal,
         alignment: Alignment = .center) {
        self.keyboardType = keyboardType
        self.textInputAutocapitalization = textInputAutocapitalization
        self.maxLength = maxLength
        self.submitLabel = submitLabel
        self.lineLimitCount = lineLimitCount
        self.haslineLimitReservedSpace = haslineLimitReservedSpace
        self.axisFont = axisFont
        self.alignment = alignment
    }

    static var defaultConfig = BaseTextFieldConfig(
        keyboardType: .default,
        textInputAutocapitalization: .never,
        maxLength: 999,
        submitLabel: .done,
        lineLimitCount: 1
    )

    static var search = BaseTextFieldConfig(
        keyboardType: .default,
        textInputAutocapitalization: .never,
        maxLength: 999,
        submitLabel: .search,
        lineLimitCount: 1
    )

    static var email = BaseTextFieldConfig(
        keyboardType: .emailAddress,
        textInputAutocapitalization: .never,
        maxLength: 100,
        submitLabel: .done,
        lineLimitCount: 1
    )

    static var note = BaseTextFieldConfig(
        keyboardType: .default,
        textInputAutocapitalization: .never,
        maxLength: 100,
        submitLabel: .done,
        lineLimitCount: 5,
        haslineLimitReservedSpace: true,
        axisFont: .vertical
    )
}
