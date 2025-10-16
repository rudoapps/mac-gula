//
//  RegisterViewModel.swift
//  Gula
//
//  Created by María on 31/7/24.
//

import Foundation

@available(macOS 15.0, *)
class RegisterViewModel: ObservableObject {
    // MARK: - Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var repeatedPassword: String = ""
    @Published var fullName: String = ""

    @Published var emailValidationResult: ValidationResult = .success
    @Published var passwordValidationResult: ValidationResult = .success
    @Published var nameValidationResult: ValidationResult = .success
    @Published var repeatedPasswordValidationResult: ValidationResult = .success

    @Published var isLoading: Bool = false

    private let authUseCase: AuthUseCaseProtocol
    private let router: RegisterRouter

    // MARK: - Init
    init(
        authUseCase: AuthUseCaseProtocol,
        router: RegisterRouter
    ) {
        self.authUseCase = authUseCase
        self.router = router
    }

    // MARK: - Functions
    @MainActor
    func createAccountIfAreValidFields() {
        if areAllFieldsValid() {
            createAccount()
        } else {
            router.showToastWithCloseAction(with: "register_notAllFieldsValid")
        }
    }

    @MainActor
    private func createAccount() {
        Task {
            do {
                isLoading = true
                defer { isLoading = false }
                try await authUseCase.createAccount(fullName: fullName, email: email, password: password)
                router.goToConfirmEmail(email)
            } catch {
                if let error = error as? AuthError {
                    handle(error)
                } else {
                    router.showError(error)
                }
            }
        }
    }

    private func areAllFieldsValid() -> Bool {
        return [emailValidationResult, passwordValidationResult, nameValidationResult, repeatedPasswordValidationResult].allSatisfy { $0 == .success }
    }

    @MainActor
    private func handle(_ error: AuthError) {
        switch error {
        case .inputEmailError:
            emailValidationResult = .failure(message: error.message)
        case .inputPasswordError:
            passwordValidationResult = .failure(message: error.message)
        case .inputUsernameError:
            nameValidationResult = .failure(message: error.message)
        case .inputsError(let fields, let messages):
            fields.enumerated().forEach { index, field in
                if field == "email" {
                    emailValidationResult = .failure(message: messages[index])
                }
                if field == "password" {
                    passwordValidationResult = .failure(message: messages[index])
                }
                if field == "username" {
                    nameValidationResult = .failure(message: messages[index])
                }
            }
        default:
            router.showAuthError(error) { [weak self] in
                guard let self else { return }
                if error.title == "common_connectionError" {
                    self.createAccount()
                }
            }
        }
    }
}

// MARK: - Navigation
@available(macOS 15.0, *)
extension RegisterViewModel {
    func dismiss() {
        router.dismiss()
    }
}
