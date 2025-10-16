//
//  StandardTextField.swift
//  Fields
//
//  Created by Adrian Prieto Villena on 27/8/25.
//

import SwiftUI

struct StandardTextField: View {
    @Binding var text: String
    @FocusState var isFocused: Bool

    var title: LocalizedStringKey?
    var subtitle: Text?
    var placeholder: LocalizedStringKey
    var isDisabled: Bool

    @Binding var validationResult: ValidationResult
    var onTextChange: (() -> Void)?

    var fieldContainerStyle: FieldContainerStyle
    var textFieldStyle: BaseTextFieldStyle
    var textFieldConfig: BaseTextFieldConfig

    private var validator: Validator

    init(
        text: Binding<String>,
        isFocused: FocusState<Bool>,
        title: LocalizedStringKey? = nil,
        subtitle: Text? = nil,
        placeholder: LocalizedStringKey,
        isDisabled: Bool = false,
        validationResult: Binding<ValidationResult> = .constant(.success),
        onTextChange: (() -> Void)? = nil,
        fieldContainerStyle: FieldContainerStyle = .defaultStyle,
        textFieldStyle: BaseTextFieldStyle = .defaultStyle,
        textFieldConfig: BaseTextFieldConfig = .defaultConfig,
        validations: [Validation] = []
    ) {
        self._text = text
        self._isFocused = isFocused
        self.title = title
        self.subtitle = subtitle
        self.placeholder = placeholder
        self.isDisabled = isDisabled
        self._validationResult = validationResult
        self.onTextChange = onTextChange
        self.fieldContainerStyle = fieldContainerStyle
        self.textFieldStyle = textFieldStyle
        self.textFieldConfig = textFieldConfig
        self.validator = Validator(validations: validations)
    }

    var body: some View {
        FieldContainer(
            title: title,
            subtitle: subtitle,
            content:  {
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
            },
            isFocused: _isFocused,
            validationResult: validationResult,
            style: fieldContainerStyle
        )
    }

    func validate() {
        validationResult = validator.validate(text)
    }
}
