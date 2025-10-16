//
//  RegisterCompletedViewModel.swift
//  Gula
//
//  Created by María on 5/8/24.
//

import Foundation

class RegisterCompletedViewModel: ObservableObject {
    private let router: RegisterCompletedRouter

    init(router: RegisterCompletedRouter) {
        self.router = router
    }
}

// MARK: - Navigation
extension RegisterCompletedViewModel {
    // TODO: -  Remove in destination app
    func goToMainMenu() {
        router.goToMainMenu()
    }
}
