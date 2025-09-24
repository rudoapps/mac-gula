//
//  ChatFloatingButtonViewModel.swift
//
//
//  Created by Axel Pérez Gaspar on 18/9/24.
//

import SwiftUI

@available(macOS 15.0, *)
final class ChatFloatingButtonViewModel: ObservableObject {
    private let useCase: ChatUseCaseProtocol
    private let router: ChatFloatingButtonRouter
    private let appearance: ChatAppearance
    @Published var configuration: ChatConfiguration?

    init(useCase: ChatUseCaseProtocol, appearance: ChatAppearance, router: ChatFloatingButtonRouter) {
        self.useCase = useCase
        self.appearance = appearance
        self.router = router
    }
    
    @MainActor
    func getConfiguration() {
        Task {
            do {
                configuration = try await useCase.getConfiguration(of: appearance.rawValue)
            } catch {
                router.showError(error)
            }
        }
    }
}

@available(macOS 15.0, *)
extension ChatFloatingButtonViewModel {
    func goToChat() {
        if let customerID = configuration?.customerID {
            router.goToChat(customerID: customerID)
        }
    }
}
