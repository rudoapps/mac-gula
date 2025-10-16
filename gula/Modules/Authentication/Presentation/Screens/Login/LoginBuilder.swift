//
//  LoginBuilder.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 5/7/24.
//

import Foundation

@available(macOS 15.0, *)
class LoginBuilder {
    func build(isSocialLoginActived: Bool) -> LoginView {
        let authUseCase = AuthContainer.makeUseCase()

        let router = LoginRouter()
        let viewModel = LoginViewModel(authUseCase: authUseCase, router: router)
        let view = LoginView(viewModel: viewModel, isSocialLoginActived: isSocialLoginActived)
        return view
    }
}
