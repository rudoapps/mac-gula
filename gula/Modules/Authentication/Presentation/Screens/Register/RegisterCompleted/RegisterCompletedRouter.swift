//
//  RegisterCompletedRouter.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/8/25.
//

import Foundation

@available(macOS 15.0, *)
class RegisterCompletedRouter: Router {
    // TODO: -  Remove in destination app
    func goToMainMenu() {
        navigator.replaceRoot(to: AppFlowView())
    }
}
