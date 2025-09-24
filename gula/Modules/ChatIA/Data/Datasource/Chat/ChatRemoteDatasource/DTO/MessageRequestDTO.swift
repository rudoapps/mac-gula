//
//  MessageRequestDTO.swift
//
//
//  Created by Axel Pérez Gaspar on 12/8/24.
//

import Foundation

struct MessageRequestDTO: Codable {
    let chatID: Int
    let content: String
    let assistantID: Int
    
    enum CodingKeys: String, CodingKey {
        case chatID = "chat_id"
        case content
        case assistantID = "assistant_id"
    }
}
