//
//  RecoverPasswordViewModel.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 17/7/24.
//

import Foundation

@available(macOS 15.0, *)
class RecoverPasswordViewModel: ObservableObject {
    // MARK: - Properties
    @Published var email: String = ""

    private let authUseCase: AuthUseCaseProtocol
    private let router: RecoverPasswordRouter
    @Published var emailValidationResult: ValidationResult = .success
    @Published var isLoading = false

    // MARK: - Init
    init(
        authUseCase: AuthUseCaseProtocol,
        router: RecoverPasswordRouter
    ) {
        self.authUseCase = authUseCase
        self.router = router
    }

    // MARK: - Functions
    @MainActor
    func recoverPassword() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                if emailValidationResult == .success {
                    try await authUseCase.recoverPassword(with: email)
                    router.goToResendLinkView(with: email)
                    router.showToastWithCloseAction(with: "auth_linkSent")
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
}

// MARK: - Private functions
@available(macOS 15.0, *)
private extension RecoverPasswordViewModel {
    @MainActor
    func handle(_ error: AuthError) {
        switch error {
        case .inputEmailError:
            emailValidationResult = .failure(message: error.message)
        case .inputsError(let fields, let messages):
            for (index, field) in fields.enumerated() where field == "email" {
                emailValidationResult = .failure(message: messages[index])
            }
        case .notVerified:
            router.showNotVerifiedAlert(error, resendAction: { [weak self] in
                guard let self else { return }
                self.recoverPassword()
            })
        default:
            router.showError(error)
        }
    }
}

// MARK: - Navigation
@available(macOS 15.0, *)
extension RecoverPasswordViewModel {
    func dismiss() {
        router.dismiss()
    }
}
