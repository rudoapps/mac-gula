//
//  PhoneTextField.swift
//  Fields
//
//  Created by Adrian Prieto Villena on 27/8/25.
//

import SwiftUI

struct PhoneTextField: View {
    @Binding var text: String
    @FocusState var isFocused: Bool

    var title: LocalizedStringKey?
    var subtitle: Text?
    var placeholder: LocalizedStringKey
    var isDisabled: Bool
    @Binding var selectedPrefix: Prefix?

    @Binding var validationResult: ValidationResult
    var onTextChange: (() -> Void)?
    var onTapPrefix: () -> Void

    @State var fieldContainerStyle: FieldContainerStyle
    var textFieldStyle: BaseTextFieldStyle
    var textFieldConfig: BaseTextFieldConfig

    var validator: Validator

    init(
        text: Binding<String>,
        isFocused: FocusState<Bool>,
        title: LocalizedStringKey? = nil,
        subtitle: Text? = nil,
        placeholder: LocalizedStringKey,
        isDisabled: Bool = false,
        selectedPrefix: Binding<Prefix?>,
        validationResult: Binding<ValidationResult>,
        onTextChange: (() -> Void)? = nil,
        onTapPrefix: @escaping () -> Void,
        fieldContainerStyle: FieldContainerStyle = .defaultStyle,
        textFieldStyle: BaseTextFieldStyle = .defaultStyle,
        textFieldConfig: BaseTextFieldConfig = .defaultConfig,
        validations: [Validation]
    ) {
        self._text = text
        self._isFocused = isFocused
        self.title = title
        self.subtitle = subtitle
        self.placeholder = placeholder
        self.isDisabled = isDisabled
        self._selectedPrefix = selectedPrefix
        self._validationResult = validationResult
        self.onTextChange = onTextChange
        self.onTapPrefix = onTapPrefix
        self.fieldContainerStyle = fieldContainerStyle
        self.textFieldStyle = textFieldStyle
        self.textFieldConfig = textFieldConfig
        self.validator = Validator(validations: validations)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            FieldContainer(
                title: title,
                subtitle: subtitle,
                content:  {
                    prefixesWithTextField()
                },
                isFocused: _isFocused,
                validationResult: validationResult,
                style: fieldContainerStyle
            )
        }
    }


    @ViewBuilder
    private func prefixesWithTextField() -> some View {
        VStack(spacing: 0) {
            HStack {
                if let selectedPrefix {
                    HStack {
                        Text("\(selectedPrefix.prefix)")
                        Image(systemName: "chevron.right")
                    }
                    .onTapGesture {
                        onTapPrefix()
                    }

                    Divider()
                }

                BaseTextField(
                    text: $text,
                    isFocused: _isFocused,
                    placeholder: placeholder,
                    isDisabled: isDisabled,
                    onTextChange: {
                        validate()
                        onTextChange?()
                    },
                    configuration: textFieldConfig,
                    style: textFieldStyle
                )
            }
        }
    }

    func validate() {
        validationResult = validator.validate(text)
    }
}
