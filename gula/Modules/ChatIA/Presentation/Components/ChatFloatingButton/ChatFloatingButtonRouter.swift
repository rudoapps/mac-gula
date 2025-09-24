//
//  ChatFloatingButtonRouter.swift
//  Gula
//
//  Created by Eduard on 19/8/25.
//

import Foundation

@available(macOS 15.0, *)
class ChatFloatingButtonRouter: Router {
    func goToChat(customerID: Int) {
        navigator.push(to: ChatBuilder.build(customerID: customerID))
    }
}
