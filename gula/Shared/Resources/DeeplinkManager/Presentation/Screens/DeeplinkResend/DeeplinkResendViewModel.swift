//
//  Gula
//
//  DeeplinkResendViewModel.swift
//
//  Created by Rudo Apps on 9/5/25
//

import Foundation

@available(macOS 15.0, *)
final class DeeplinkResendViewModel: ObservableObject {
    private let useCase: DeeplinkManagerUseCaseProtocol
    private let router: DeeplinkResendRouter
    let config: DeeplinkResendConfig

    init(useCase: DeeplinkManagerUseCaseProtocol,
         config: DeeplinkResendConfig,
         router: DeeplinkResendRouter) {
        self.useCase = useCase
        self.config = config
        self.router = router
    }

    @MainActor
    func resendLinkVerification() {
        Task {
            do {
                try await useCase.resendLinkVerification(email: config.email)
                router.showToastWithCloseAction(with: "auth_changeEmailSent")
            } catch {
                router.showError(error)
            }
        }
    }
}

// MARK: - Navigation
@available(macOS 15.0, *)
extension DeeplinkResendViewModel {
    func dismiss() {
        router.dismiss()
    }

    // TODO: -  Remove in destination app
    func goToMainMenu() {
        router.goToMainMenu()
    }
}
