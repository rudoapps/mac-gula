//
//  Message.swift
//
//
//  Created by Jorge on 24/7/24.
//

import Foundation

struct Message: Hashable, Identifiable {
    enum MessageType: String {
        case user
        case bot = "assistant"
        case loading
        case error
        case warning
    }

    let id = UUID()
    let message: String
    let type: MessageType

    init(_ message: String, type: MessageType) {
        self.message = message
        self.type = type
    }
}
