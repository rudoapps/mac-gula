//
//  FieldContainer.swift
//  Fields
//
//  Created by Adrian Prieto Villena on 27/8/25.
//

import SwiftUI

struct FieldContainer: View {
    var title: LocalizedStringKey? = nil
    var subtitle: Text? = nil
    @ViewBuilder let content: any View
    @FocusState var isFocused: Bool
    var validationResult: ValidationResult
    var footerMessage: LocalizedStringKey = ""
    var style: FieldContainerStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(style.titleFont)
                        .foregroundColor(style.titleColor)

                    if let subtitle {
                        subtitle
                            .font(style.subtitleFont)
                            .foregroundColor(validationResult != .success ? style.errorColor : style.subtitleColor)
                    }
                }
                .padding(.bottom, 4)
            }

            AnyView(content)
                .padding(style.padding)
                .frame(maxWidth: .infinity,
                       minHeight: style.maxHeight,
                       maxHeight: style.maxHeight,
                       alignment: .topLeading)
                .background(
                    style.roundedCorner
                        .stroke(strokeColor, lineWidth: 1)
                        .fill(style.backgroundColor)
                )

            switch validationResult {
            case .success:
                Text(footerMessage)
                    .font(style.messageFont)
                    .foregroundColor(.gray)
            case .failure(let message):
                Text(LocalizedStringKey(message))
                    .font(style.messageFont)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var strokeColor: Color {
        if isFocused, validationResult == .success {
            return style.focusBorderColor
        }

        switch validationResult {
        case .success:
            return style.defaultBorderColor
        case .failure:
            return style.errorColor
        }
    }
}
