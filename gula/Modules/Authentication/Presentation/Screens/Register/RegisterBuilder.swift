//
//  RegisterBuilder.swift
//  Gula
//
//  Created by María on 31/7/24.
//

import Foundation

@available(macOS 15.0, *)
class RegisterBuilder {
    func build() -> RegisterView {
        let authUseCase = AuthContainer.makeUseCase()

        let router = RegisterRouter()
        let viewModel = RegisterViewModel(authUseCase: authUseCase, router: router)
        let view = RegisterView(viewModel: viewModel)
        return view
    }
}
