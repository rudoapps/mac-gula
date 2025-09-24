//
//  ChatBuilder.swift
//  
//
//  Created by Jorge on 23/7/24.
//

import Foundation

@available(macOS 15.0, *)
final class ChatBuilder {
    static func build(customerID: Int) -> ChatView {
        let useCase = ChatIAContainer.makeUseCase()
        let router = ChatRouter()
        let viewModel = ChatViewModel(useCase: useCase,
                                      customerID: customerID,
                                      router: router)
        return ChatView(viewModel: viewModel)
    }
}
