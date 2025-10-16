//
//  NewPasswordView.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 22/7/24.
//

import SwiftUI

@available(macOS 15.0, *)
struct NewPasswordView: View {
    @ObservedObject var viewModel: NewPasswordViewModel
    @FocusState var isFocusedNewPasswordTextField: Bool
    @FocusState var isFocusedRepeatPasswordTextField: Bool
    @State var sendButtonState: ButtonState = .normal

    var body: some View {
        VStack(alignment: .leading) {
            header
            fields
            Spacer()
        }
        .onChange(of: viewModel.isLoading) {
            sendButtonState = viewModel.isLoading ? .loading : .normal
        }
        .ignoresSafeArea(.keyboard, edges: .all)
        .padding(.horizontal, 16)
        .toolbar {
            setupToolbar()
        }
        #if os(iOS)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Private views
@available(macOS 15.0, *)
private extension NewPasswordView {
    var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("auth_writeNewPassword")
                .font(.system(size: 16, weight: .semibold))
            Text("auth_newPasswordInformation")
                .font(.system(size: 16, weight: .regular))
                .lineSpacing(8)
        }
        .padding(.bottom, viewModel.userId != nil ? 44 : 32)
        .padding(.top, 24)
    }

    var fields: some View {
        VStack {
            passwordTextField

            repeatedPasswordTextField

            CustomButton(
                buttonState: $sendButtonState,
                type: .primary,
                buttonText: "auth_update"
            ) {
                isFocusedNewPasswordTextField = false
                isFocusedRepeatPasswordTextField = false

                if viewModel.areFieldsValids() {
                    viewModel.changePassword()
                }
            }
        }
    }

    @ToolbarContentBuilder
    func setupToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("auth_newPassword")
                .font(.system(size: 20))
                .foregroundStyle(.white)
        }
        #if os(iOS)
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                Button {
                    // TODO: -  Remove in destination app
                    viewModel.goToMainMenu()
                } label: {
                    toolBarBackButtonImage(systemName: "xmark")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(maxWidth: 16, maxHeight: 16)
                }
            }
        }
        #else
        ToolbarItem(placement: .automatic) {
            HStack {
                Button {
                    // TODO: -  Remove in destination app
                    viewModel.goToMainMenu()
                } label: {
                    toolBarBackButtonImage(systemName: "xmark")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(maxWidth: 16, maxHeight: 16)
                }
            }
        }
        #endif
    }

    func toolBarBackButtonImage(systemName: String) -> Image {
        Image(systemName: systemName)
    }

    var passwordTextField: some View {
        ProfessionalTextField(
            title: NSLocalizedString("auth_newPassword", comment: ""),
            placeholder: NSLocalizedString("auth_newPassword", comment: ""),
            icon: "lock",
            text: $viewModel.password,
            isSecure: true,
            validation: { password in
                if password.isEmpty {
                    return ProfessionalTextField.ValidationResult(
                        isValid: false,
                        message: NSLocalizedString("auth_passwordRequired", comment: "")
                    )
                } else if password.count > 15 {
                    return ProfessionalTextField.ValidationResult(
                        isValid: false,
                        message: NSLocalizedString("auth_passwordTooLong", comment: "")
                    )
                } else if password.count < 6 {
                    return ProfessionalTextField.ValidationResult(
                        isValid: false,
                        message: NSLocalizedString("auth_passwordTooShort", comment: "")
                    )
                }
                return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
            }
        )
    }

    var repeatedPasswordTextField: some View {
        ProfessionalTextField(
            title: NSLocalizedString("auth_repeatPassword", comment: ""),
            placeholder: NSLocalizedString("auth_repeatNewPassword", comment: ""),
            icon: "lock.fill",
            text: $viewModel.repeatPassword,
            isSecure: true,
            validation: { repeatPassword in
                if repeatPassword.isEmpty {
                    return ProfessionalTextField.ValidationResult(
                        isValid: false,
                        message: NSLocalizedString("auth_passwordRequired", comment: "")
                    )
                } else if repeatPassword.count > 15 {
                    return ProfessionalTextField.ValidationResult(
                        isValid: false,
                        message: NSLocalizedString("auth_passwordTooLong", comment: "")
                    )
                } else if repeatPassword != viewModel.password {
                    return ProfessionalTextField.ValidationResult(
                        isValid: false,
                        message: NSLocalizedString("auth_passwordsDoNotMatch", comment: "")
                    )
                }
                return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
            }
        )
    }
}
