//
//  NewPasswordBuilder.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 22/7/24.
//

import Foundation

@available(macOS 15.0, *)
class NewPasswordBuilder {
    func build(with id: String?) -> NewPasswordView {
        let authUseCase = AuthContainer.makeUseCase()

        let router = NewPasswordRouter()
        let viewModel = NewPasswordViewModel(userId: id,
                                             authUseCase: authUseCase,
                                             router: router)
        let view = NewPasswordView(viewModel: viewModel)
        return view
    }
}
