//
//  LoginViewModel.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 4/7/24.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn

#if canImport(AppKit)
import AppKit
#endif

@available(macOS 15.0, *)
class LoginViewModel: NSObject, ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""

    @Published var emailValidationResult: ValidationResult = .success
    @Published var passwordValidationResult: ValidationResult = .success
    @Published var showToast = false
    @Published var allFieldsAreValid = false

    private let authUseCase: AuthUseCaseProtocol
    private let router: LoginRouter

    init(authUseCase: AuthUseCaseProtocol,
         router: LoginRouter) {
        self.authUseCase = authUseCase
        self.router = router
    }

    @MainActor
    func login() {
        Task {
            do {
                if areValidsFields() {
                    try await authUseCase.login(with: email, and: password)
                }
            } catch {
                if let error = error as? AuthError {
                    handle(error)
                } else {
                    router.showError(error)
                }
            }
        }
    }

    @MainActor
    func resentVerificationLink() {
        Task {
            do {
                if !email.isEmpty {
                    try await authUseCase.recoverPassword(with: email)
                }
            } catch {
                if let error = error as? AuthError {
                    handle(error)
                } else {
                    router.showError(error)
                }
            }
        }
    }

    private func areValidsFields() -> Bool {
        emailValidationResult == .success &&
        passwordValidationResult == .success
    }

    private func handle(_ error: AuthError) {
        switch error {
        case .inputEmailError:
            emailValidationResult = .failure(message: error.message)
        case .inputPasswordError:
            passwordValidationResult = .failure(message: error.message)
        case .inputsError(let fields, let messages):
            fields.enumerated().forEach { index, field in
                if field == "email" {
                    emailValidationResult = .failure(message: messages[index])
                }
                if field == "password" {
                    passwordValidationResult = .failure(message: messages[index])
                }
            }
        case .notVerified:
            router.showNotVerifiedAlert(error, resendAction: {})
        default:
            router.showAuthError(error)
        }
    }
}

// MARK: - Apple Login
@available(macOS 15.0, *)
extension LoginViewModel: ASAuthorizationControllerDelegate {
    func loginWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    @MainActor
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let authorizationCode = appleIDCredential.authorizationCode,
           let code = String(data: authorizationCode, encoding: .utf8) {
            loginWithApple(code: code)
        }
    }

    @MainActor
    private func loginWithApple(code: String) {
        Task {
            do {
                try await authUseCase.loginWithApple(code: code)
            } catch {
                if let error = error as? AuthError {
                    handle(error)
                } else {
                    router.showError(error)
                }
            }
        }
    }
}

// MARK: - Google Login
@available(macOS 15.0, *)
extension LoginViewModel {
    @MainActor
    func loginWithGoogle() {
        Task {
            do {
                #if canImport(UIKit)
                if let rootViewController = getRootViewController(),
                   let result = try? await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController),
                   let token = result.user.idToken?.tokenString {
                    try await authUseCase.loginWithGoogle(token: token)
                } else {
                    throw AppError.generalError
                }
                #elseif canImport(AppKit)
                if let window = getCurrentWindow(),
                   let result = try? await GIDSignIn.sharedInstance.signIn(withPresenting: window),
                   let token = result.user.idToken?.tokenString {
                    try await authUseCase.loginWithGoogle(token: token)
                } else {
                    throw AppError.generalError
                }
                #else
                throw AppError.generalError
                #endif
            } catch {
                if let error = error as? AuthError {
                    handle(error)
                } else {
                    router.showError(error)
                }
            }
        }
    }

    #if canImport(UIKit)
    private func getRootViewController() -> UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    #endif

    #if canImport(AppKit)
    private func getCurrentWindow() -> NSWindow? {
        return NSApplication.shared.windows.first { $0.isKeyWindow }
            ?? NSApplication.shared.windows.first
    }
    #endif
}

// MARK: - Navigation
@available(macOS 15.0, *)
extension LoginViewModel {
    func dismiss() {
        router.dismiss()
    }

    func goToRegister() {
        router.goToRegister()
    }

    func goToRecoverPassword() {
        router.goToRecoverPassword()
    }
}
