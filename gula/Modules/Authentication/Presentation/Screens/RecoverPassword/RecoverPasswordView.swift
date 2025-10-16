//
//  RecoverPasswordView.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 17/7/24.
//

import SwiftUI

@available(macOS 15.0, *)
struct RecoverPasswordView: View {
    @ObservedObject var viewModel: RecoverPasswordViewModel
    @FocusState var isFocusedEmailTextField: Bool
    @State var sendButtonState: ButtonState = .normal

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            header
            VStack {
                emailTextField
                CustomButton(
                    buttonState: $sendButtonState,
                    type: .primary,
                    buttonText: "auth_send"
                ) {
                    isFocusedEmailTextField = false
                    viewModel.recoverPassword()
                }
            }
            Spacer()
        }
        .onChange(of: viewModel.isLoading) {
            sendButtonState = viewModel.isLoading ? .loading : .normal
        }
        .padding(.horizontal, 16)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationBarBackButtonHidden()
        .toolbar {
            setupToolbar()
        }
        #if os(iOS)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        #endif
    }
}

// MARK: - Private views
@available(macOS 15.0, *)
private extension RecoverPasswordView {
    var header: some View {
        Text("auth_recoverPasswordInfo")
            .multilineTextAlignment(.leading)
            .font(.system(size: 14))
            .padding(.top, 24)
    }

    @ToolbarContentBuilder
    func setupToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("auth_recoverPassword")
                .font(.system(size: 20))
                .foregroundStyle(.white)
        }
        #if os(iOS)
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                Button {
                    viewModel.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(maxWidth: 16, maxHeight: 16)
                        .foregroundColor(.white)
                }
            }
        }
        #else
        ToolbarItem(placement: .automatic) {
            HStack {
                Button {
                    viewModel.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(maxWidth: 16, maxHeight: 16)
                        .foregroundColor(.white)
                }
            }
        }
        #endif
    }

    var emailTextField: some View {
        ProfessionalTextField(
            title: NSLocalizedString("auth_email", comment: ""),
            placeholder: NSLocalizedString("auth_writeEmail", comment: ""),
            icon: "envelope",
            text: $viewModel.email,
            validation: { email in
                if email.isEmpty {
                    return ProfessionalTextField.ValidationResult(
                        isValid: false,
                        message: NSLocalizedString("auth_emailRequired", comment: "")
                    )
                } else if !email.contains("@") || !email.contains(".") {
                    return ProfessionalTextField.ValidationResult(
                        isValid: false,
                        message: NSLocalizedString("auth_invalidEmail", comment: "")
                    )
                }
                return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
            }
        )
    }
}
