//
//  Router.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 31/7/25.
//

import SwiftUI

class Router {
    var navigator: NavigatorProtocol

    init(navigator: NavigatorProtocol = Navigator.shared) {
        self.navigator = navigator
    }

    // MARK: - Alerts
    func showError(_ error: Error, action: @escaping () -> Void = {}) {
        navigator.showErrorAlert(error, action: action)
    }

    // MARK: - Toasts
    func showToastWithCloseAction(with message: LocalizedStringKey, closeAction: @escaping () -> Void = {}) {
        let toastView = ToastView(
            message: message,
            isCloseButtonActive: true, closeAction: { [weak self] in
                guard let self else { return }
                self.navigator.dismissToast()
                closeAction()
            }
        )

        navigator.showToast(from: ToastConfig(view: toastView))
    }

    // MARK: - Navigation actions
    func dismiss() {
        navigator.dismiss()
    }

    func dismissSheet() {
        navigator.dismissSheet()
    }

    func dismissFullOverScreen() {
        navigator.dismissFullOverScreen()
    }
}
