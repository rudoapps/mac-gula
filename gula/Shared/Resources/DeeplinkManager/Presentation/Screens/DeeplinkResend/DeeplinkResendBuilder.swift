//
//  Gula
//
//  DeeplinkResendBuilder.swift
//
//  Created by Rudo Apps on 9/5/25
//

@available(macOS 15.0, *)
final class DeeplinkResendBuilder {
    func build(with config: DeeplinkResendConfig) -> DeeplinkResendView {
        let useCase = DeeplinkContainer.makeUseCase()
        let router = DeeplinkResendRouter()
        let viewModel = DeeplinkResendViewModel(useCase: useCase, config: config, router: router)
        let view = DeeplinkResendView(viewModel: viewModel)
        return view
    }
}
