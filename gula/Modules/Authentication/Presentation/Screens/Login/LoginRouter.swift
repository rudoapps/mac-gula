//
//  LoginRouter.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 4/8/25.
//

import Foundation

@available(macOS 15.0, *)
class LoginRouter: AuthenticationRouter {
    func goToRecoverPassword() {
        navigator.push(to: RecoverPasswordBuilder().build())
    }

    func goToRegister() {
        navigator.push(to: RegisterBuilder().build())
    }
}
