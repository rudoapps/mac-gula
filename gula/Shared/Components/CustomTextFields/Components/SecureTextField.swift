//
//  SecureTextField.swift
//  Fields
//
//  Created by Adrian Prieto Villena on 27/8/25.
//


import SwiftUI

struct SecureTextField: View {
    @Binding var text: String
    @Binding var isSecured: Bool
    @FocusState var isFocused: Bool
    
    let placeholder: LocalizedStringKey
    let isDisabled: Bool
    let onTextChange: (() -> Void)?

    var configuration: BaseTextFieldConfig
    var style: BaseTextFieldStyle

    var body: some View {
        HStack(spacing: 8) {
            Group {
                if isSecured {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(style.font)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: configuration.alignment)
            .focused($isFocused)
            .disabled(isDisabled)
            .foregroundStyle(isDisabled ? style.disabledColor : style.textColor)
            .onChange(of: text) {
                onTextChange?()
            }
            
            Button {
                isSecured.toggle()
            } label: {
                Image(systemName: isSecured ? "eye" : "eye.slash")
                    .foregroundColor(.gray)
            }
        }
    }
}
