//
//  NewPasswordRouter.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 6/8/25.
//

import SwiftUI

class NewPasswordRouter: AuthenticationRouter {
    // TODO: -  Remove in destination app
    func goToMainMenu() {
        navigator.replaceRoot(to: AppFlowView())
    }

    func showUpdatedPasswordAlert() {
        let config = AlertConfig(title: "auth_passwordUpdated", message: "auth_passwordUpdatedInfo", actions: {
            Button("common_accept") {
                self.goToMainMenu()
            }
        })
        navigator.showAlert(from: config)
    }
}
