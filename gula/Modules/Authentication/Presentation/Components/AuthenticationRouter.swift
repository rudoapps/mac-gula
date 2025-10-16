//
//  AuthenticationRouter.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 4/8/25.
//

import SwiftUI

class AuthenticationRouter: Router {
    func showAuthError(_ error: AuthError, action: @escaping () -> Void = {}) {
        let config = AlertConfig(title: LocalizedStringKey(error.title),
                                 message: LocalizedStringKey(error.message),
                                 actions: {
            Button("common_accept"){}
        })
        navigator.showAlert(from: config)
    }

    func showNotVerifiedAlert(_ error: AuthError, resendAction: @escaping () -> Void) {
        let config = AlertConfig(title: LocalizedStringKey(error.title),
                                 message: LocalizedStringKey(error.message),
                                 actions: {
            VStack {
                Button("common_accept"){}
                Button("auth_resend"){
                    resendAction()
                }
            }
        })
        navigator.showAlert(from: config)
    }
}
