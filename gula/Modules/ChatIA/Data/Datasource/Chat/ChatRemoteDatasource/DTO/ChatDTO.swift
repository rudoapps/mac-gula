//
//  ChatResponseDTO.swift
//
//
//  Created by Axel Pérez Gaspar on 12/8/24.
//

import Foundation

struct ChatDataDTO: Codable {
    let data: ChatDTO
    let error: ChatErrorDTO?
}

struct ChatDTO: Codable {
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "chat_id"
    }
}
