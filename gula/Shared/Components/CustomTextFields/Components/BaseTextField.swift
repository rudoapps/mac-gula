//
//  BaseTextField.swift
//  Fields
//
//  Created by Adrian Prieto Villena on 27/8/25.
//

import SwiftUI

struct BaseTextField: View {
    @Binding var text: String
    @FocusState var isFocused: Bool
    
    var placeholder: LocalizedStringKey
    var isDisabled: Bool = false
    var onTextChange: (() -> Void)? = nil
    var onSubmit: () -> Void = {}
    var configuration: BaseTextFieldConfig
    var style: BaseTextFieldStyle

    var body: some View {
        HStack(spacing: 8) {
            #if canImport(UIKit)
            TextField(
                placeholder,
                text: $text,
                axis: configuration.axisFont
            )
            .font(style.font)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: configuration.alignment)
            .textInputAutocapitalization(configuration.textInputAutocapitalization)
            .keyboardType(configuration.keyboardType)
            .focused($isFocused)
            .disabled(isDisabled)
            .foregroundStyle(isDisabled ? style.disabledColor : style.textColor)
            .lineLimit(
                configuration.lineLimitCount,
                reservesSpace: configuration.haslineLimitReservedSpace
            )
            .onChange(of: text) { _, newValue in
                text = String(newValue.prefix(configuration.maxLength))
                onTextChange?()
            }
            .onSubmit {
                onSubmit()
            }
            .submitLabel(configuration.submitLabel)
            #else
            TextField(
                placeholder,
                text: $text,
                axis: configuration.axisFont
            )
            .font(style.font)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: configuration.alignment)
            .focused($isFocused)
            .disabled(isDisabled)
            .foregroundStyle(isDisabled ? style.disabledColor : style.textColor)
            .lineLimit(
                configuration.lineLimitCount,
                reservesSpace: configuration.haslineLimitReservedSpace
            )
            .onChange(of: text) { _, newValue in
                text = String(newValue.prefix(configuration.maxLength))
                onTextChange?()
            }
            .onSubmit {
                onSubmit()
            }
            .submitLabel(configuration.submitLabel)
            #endif
        }
    }
}
