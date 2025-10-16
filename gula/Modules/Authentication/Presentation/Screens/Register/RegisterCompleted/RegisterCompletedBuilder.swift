//
//  RegisterCompletedBuilder.swift
//  Gula
//
//  Created by María on 5/8/24.
//

import Foundation

@available(macOS 15.0, *)
class RegisterCompletedBuilder {
    func build() -> RegisterCompletedView {
        let router = RegisterCompletedRouter()
        let viewModel = RegisterCompletedViewModel(router: router)
        let view = RegisterCompletedView(viewModel: viewModel)
        return view
    }
}
