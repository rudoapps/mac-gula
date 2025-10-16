//
//  RegisterCompletedRouter.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/8/25.
//

import Foundation

class RegisterCompletedRouter: Router {
    // TODO: -  Remove in destination app
    func goToMainMenu() {
        navigator.replaceRoot(to: AppFlowView())
    }
}
