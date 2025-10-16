//
//  RecoverPasswordBuilder.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 17/7/24.
//

import Foundation

@available(macOS 15.0, *)
class RecoverPasswordBuilder {
    func build() -> RecoverPasswordView {
        let authUseCase = AuthContainer.makeUseCase()
        let router = RecoverPasswordRouter()
        let viewModel = RecoverPasswordViewModel(authUseCase: authUseCase,
                                                 router: router)
        let view = RecoverPasswordView(viewModel: viewModel)
        return view
    }
}
