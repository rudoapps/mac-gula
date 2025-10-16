//
//  DeeplinkResendRouter.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/8/25.
//

import Foundation

class DeeplinkResendRouter: Router {
    // TODO: -  Remove in destination app
    func goToMainMenu() {
        navigator.replaceRoot(to: AppFlowView())
    }
}
