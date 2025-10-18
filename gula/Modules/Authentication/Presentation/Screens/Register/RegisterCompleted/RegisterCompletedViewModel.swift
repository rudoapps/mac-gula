//
//  RegisterCompletedViewModel.swift
//  Gula
//
//  Created by María on 5/8/24.
//

import Foundation

@available(macOS 15.0, *)
class RegisterCompletedViewModel: ObservableObject {
    private let router: RegisterCompletedRouter

    init(router: RegisterCompletedRouter) {
        self.router = router
    }
}

// MARK: - Navigation
@available(macOS 15.0, *)
extension RegisterCompletedViewModel {
    // TODO: -  Remove in destination app
    func goToMainMenu() {
        router.goToMainMenu()
    }
}
