//
//  MessageDTO.swift
//
//
//  Created by Axel Pérez Gaspar on 12/8/24.
//

import Foundation

struct MessageDataDTO: Codable {
    let data: [MessageDTO]
    let error: ChatErrorDTO?
}

struct MessageDTO: Codable {
    let value: String
    let role: String
}
