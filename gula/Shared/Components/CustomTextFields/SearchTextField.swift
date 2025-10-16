//
//  SearchTextField.swift
//  Fields
//
//  Created by Adrian Prieto Villena on 27/8/25.
//

import SwiftUI

struct SearchTextField: View {
    @Binding var text: String
    @FocusState var isFocused: Bool
    
    var title: LocalizedStringKey?
    var subtitle: Text?
    var placeholder: LocalizedStringKey
    var isDisabled: Bool
    var cleanTextImage: Image = Image(systemName: "arrow.left")
    var cleanTextAction: () -> Void

    @Binding var validationResult: ValidationResult
    var footerMessage: LocalizedStringKey
    var onTextChange: () -> Void
    var onSubmit: () -> Void
    var onStartTyping: () -> Void

    var fieldContainerStyle: FieldContainerStyle
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
        cleanTextImage: Image,
        cleanTextAction: @escaping () -> Void = {},
        validationResult: Binding<ValidationResult>,
        footerMessage: LocalizedStringKey,
        onTextChange: @escaping () -> Void = {},
        onSubmit: @escaping () -> Void = {},
        onStartTyping: @escaping () -> Void = {},
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
        self.cleanTextImage = cleanTextImage
        self.cleanTextAction = cleanTextAction
        self._validationResult = validationResult
        self.footerMessage = footerMessage
        self.onTextChange = onTextChange
        self.onSubmit = onSubmit
        self.onStartTyping = onStartTyping
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
                ZStack {
                    BaseTextField(
                        text: $text,
                        isFocused: _isFocused,
                        placeholder: placeholder,
                        isDisabled: isDisabled,
                        onTextChange: {
                            onTextChange()
                        },
                        onSubmit: {
                            onSubmit()
                        },
                        configuration: textFieldConfig,
                        style: textFieldStyle
                    )

                    HStack {
                        Spacer()
                        if isFocused {
                            cleanTextImage
                                .resizable()
                                .frame(width: 14, height: 14)
                                .padding(.trailing, 12)
                                .onTapGesture {
                                    cleanTextAction()
                                }
                        }
                    }
                }
            },
            isFocused: _isFocused,
            validationResult: validationResult,
            footerMessage: footerMessage,
            style: fieldContainerStyle
        )
        .onChange(of: isFocused) {
            if isFocused {
                onStartTyping()
            }
        }
    }

    func validate() {
        validationResult = validator.validate(text)
    }
}
