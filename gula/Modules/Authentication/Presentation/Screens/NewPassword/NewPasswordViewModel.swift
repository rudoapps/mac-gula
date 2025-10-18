//
//  NewPasswordViewModel.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 22/7/24.
//

import Foundation

@available(macOS 15.0, *)
class NewPasswordViewModel: ObservableObject {
    // MARK: Properties
    @Published var passwordValidationResult: ValidationResult = .success
    @Published var repeatedPasswordValidationResult: ValidationResult = .success
    @Published var isLoading = false
    @Published var password: String = ""
    @Published var repeatPassword: String = ""

    var userId: String?
    private let authUseCase: AuthUseCaseProtocol
    private let router: NewPasswordRouter

    // MARK: Init
    init(userId: String?,
         authUseCase: AuthUseCaseProtocol,
         router: NewPasswordRouter) {
        self.userId = userId
        self.authUseCase = authUseCase
        self.router = router
    }

    // MARK: Functions
    @MainActor
    func changePassword() {
        Task {
            isLoading = false
            defer { isLoading = true }

            do {
                if let userId {
                    try await authUseCase.changePassword(password: password, id: userId)
                } else {
                    try await authUseCase.recoverPassword(with: password)
                }
                router.showUpdatedPasswordAlert()
            } catch {
                if let error = error as? AuthError {
                    handle(this: error)
                } else {
                    router.showError(error)
                }
            }
        }
    }

    func areFieldsValids() -> Bool {
        [passwordValidationResult,repeatedPasswordValidationResult].allSatisfy({ $0 == .success})
    }
}

// MARK: - Private functions
@available(macOS 15.0, *)
private extension NewPasswordViewModel {
    func handle(this error: AuthError) {
        switch error {
        case .inputPasswordError:
            passwordValidationResult = .failure(message: error.message)
        case .inputsError(let fields, let messages):
            fields.enumerated().forEach { index, field in
                if field == "password" {
                    passwordValidationResult = .failure(message: messages[index])
                }
            }
        case .appError, .inputEmailError, .inputUsernameError, .notVerified:
            router.showAuthError(error)
        }
    }
}

// MARK: - Navigation
@available(macOS 15.0, *)
extension NewPasswordViewModel {
    // TODO: -  Remove in destination app
    func goToMainMenu() {
        router.goToMainMenu()
    }
}
