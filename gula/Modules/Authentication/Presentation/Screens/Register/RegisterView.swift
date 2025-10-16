//
//  RegisterView.swift
//  Gula
//
//  Created by María on 31/7/24.
//
import SwiftUI

@available(macOS 15.0, *)
struct RegisterView: View {
    @ObservedObject var viewModel: RegisterViewModel
    @State private var sendButtonState: ButtonState = .normal
    @FocusState var isFocusedFullNameTextField: Bool
    @FocusState var isFocusedPasswordTextField: Bool
    @FocusState var isFocusedEmailTextField: Bool
    @FocusState var isFocusedRepeatPasswordTextField: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Spacer()
                registerButtonView
                loginLinkView
            }
            .zIndex(1)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .padding(.horizontal, 16)

            ScrollView {
                Image(systemName: "photo.fill")
                    .resizable()
                    .frame(width: 83, height: 83)
                    .foregroundColor(Color.gray)
                    .clipShape(Circle())
                    .padding(.vertical, 32)
                fields
                    .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)

        }
        .onChange(of: viewModel.isLoading) {
            sendButtonState = viewModel.isLoading ? .loading : .normal
        }
        #if os(iOS)
        .toolbarBackground(Color.white, for: .navigationBar)
        #endif
        .toolbar {
            setupToolbar()
        }
        .navigationBarBackButtonHidden()
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    @ToolbarContentBuilder
    private func setupToolbar() -> some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .frame(maxWidth: 16, maxHeight: 16)
                    .foregroundColor(.black)
            }
        }
        #else
        ToolbarItem(placement: .automatic) {
            Button {
                viewModel.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .frame(maxWidth: 16, maxHeight: 16)
                    .foregroundColor(.black)
            }
        }
        #endif
        ToolbarItem(placement: .principal) {
            Text("auth_registerTitle")
                .font(.system(size: 18))
        }
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: 8) {
            nameTextField
            emailTextField
            passwordTextField
            repeatedPasswordTextField
        }
        .padding(.top, 24)
    }

    private var nameTextField: some View {
        ProfessionalTextField(
            title: NSLocalizedString("auth_fullName", comment: ""),
            placeholder: NSLocalizedString("auth_fullName", comment: ""),
            icon: "person",
            text: $viewModel.fullName,
            validation: { name in
                if name.isEmpty {
                    return ProfessionalTextField.ValidationResult(
                        isValid: false,
                        message: NSLocalizedString("auth_nameRequired", comment: "")
                    )
                }
                return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
            }
        )
    }

    private var emailTextField: some View {
        ProfessionalTextField(
            title: NSLocalizedString("auth_email", comment: ""),
            placeholder: NSLocalizedString("auth_email", comment: ""),
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

    private var passwordTextField: some View {
        VStack(alignment: .leading, spacing: 4) {
            ProfessionalTextField(
                title: NSLocalizedString("auth_password", comment: ""),
                placeholder: NSLocalizedString("auth_password", comment: ""),
                icon: "lock",
                text: $viewModel.password,
                isSecure: true,
                validation: { password in
                    if password.isEmpty {
                        return ProfessionalTextField.ValidationResult(
                            isValid: false,
                            message: NSLocalizedString("auth_passwordRequired", comment: "")
                        )
                    } else if password.count < 6 {
                        return ProfessionalTextField.ValidationResult(
                            isValid: false,
                            message: NSLocalizedString("register_passwordConditions", comment: "")
                        )
                    }
                    return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
                }
            )
        }
    }

    private var repeatedPasswordTextField: some View {
        ProfessionalTextField(
            title: NSLocalizedString("auth_repeatPassword", comment: ""),
            placeholder: NSLocalizedString("auth_repeatPassword", comment: ""),
            icon: "lock.fill",
            text: $viewModel.repeatedPassword,
            isSecure: true,
            validation: { repeatedPassword in
                if repeatedPassword.isEmpty {
                    return ProfessionalTextField.ValidationResult(
                        isValid: false,
                        message: NSLocalizedString("auth_passwordRequired", comment: "")
                    )
                } else if repeatedPassword != viewModel.password {
                    return ProfessionalTextField.ValidationResult(
                        isValid: false,
                        message: NSLocalizedString("auth_passwordsDoNotMatch", comment: "")
                    )
                }
                return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
            }
        )
    }

    private var registerButtonView: some View {
        CustomButton(
            buttonState: $sendButtonState,
            type: .primary,
            buttonText: "auth_createAccount") {
                removeFocusFields()
                viewModel.createAccountIfAreValidFields()
            }
    }

    private var loginLinkView: some View {
        HStack(alignment: .center) {
            Text("auth_haveAccount")
                .font(.system(size: 14))
                .foregroundColor(.black)
            Button(action: {
                viewModel.dismiss()
            }, label: {
                Text("auth_loginLowercased")
                    .underline()
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            })
        }
    }

    private func removeFocusFields() {
        isFocusedEmailTextField = false
        isFocusedPasswordTextField = false
        isFocusedFullNameTextField = false
        isFocusedRepeatPasswordTextField = false
    }

}
