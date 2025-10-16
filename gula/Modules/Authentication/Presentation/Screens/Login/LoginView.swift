//
//  LoginView.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 4/7/24.
//

import SwiftUI

@available(macOS 15.0, *)
struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @FocusState var isFocusedEmailTextField: Bool
    @FocusState var isFocusedPasswordTextField: Bool
    @State private var buttonState: ButtonState = .normal
    @State private var isFieldEmptyCheckedFromView = false
    let isSocialLoginActived: Bool

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .frame(width: 83, height: 83)
                        .foregroundColor(Color.gray)
                        .clipShape(Circle())
                        .padding(.top, 24)
                        .padding(.bottom, 16)

                    emailTextField
                    passwordTextField

                    VStack(alignment: .leading, spacing: 24) {
                        Text("auth_forgotPassword")
                            .font(.system(size: 12))
                            .foregroundStyle(.black)
                            .onTapGesture {
                                viewModel.goToRecoverPassword()
                            }
                        CustomButton(buttonState: $buttonState,
                                     type: .primary,
                                     buttonText: "auth_logIn") {
                            isFocusedEmailTextField = false
                            isFocusedPasswordTextField = false
                            isFieldEmptyCheckedFromView = viewModel.email.isEmpty || viewModel.password.isEmpty
                            viewModel.login()
                        }
                    }
                    if isSocialLoginActived {
                        socialLoginView
                            .padding(.top, 24)
                    }
                }
                .padding(.horizontal,16)
            }
            .scrollDisabled(true)
            Spacer()
            HStack(alignment: .center) {
                Text("auth_noAccountYet")
                    .font(.system(size: 14))

                Text("auth_register")
                    .font(.system(size: 14))
                    .bold()
                    .foregroundStyle(.black)
                    .underline()
                    .onTapGesture {
                        viewModel.goToRegister()
                    }
            }
            .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            setupToolbar()
        }
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
        #endif
        ToolbarItem(placement: .principal) {
            Text("auth_logIn")
                .font(.system(size: 18))
        }
    }

    private var emailTextField: some View {
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

    private var passwordTextField: some View {
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
                }
                return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
            }
        )
    }

    private var socialLoginView: some View {
        VStack {
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.gray)
                Text("auth_socialLoginTitle")
                    .lineLimit(1)
                    .font(.system(size: 12))
                    .fixedSize()
                    .foregroundStyle(Color.gray)
                Rectangle()
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.gray)
            }
            SocialLoginButton(buttonType: .apple) {
                viewModel.loginWithApple()
            }
            .padding(.top, 20)
            SocialLoginButton(buttonType: .google) {
                viewModel.loginWithGoogle()
            }
        }
    }
}
