//
//  RegisterRouter.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/8/25.
//

import Foundation

@available(macOS 15.0, *)
class RegisterRouter: AuthenticationRouter {
    func goToConfirmEmail(_ email: String) {
        navigator.push(to:
                        DeeplinkResendBuilder().build(with: .init(title: "auth_confirmEmailTitle",
                                                                  message: "auth_emailSentInfoRegister, \(email)",
                                                                  email: email,
                                                                  messageType: .emailVerification))
        )
    }
}
