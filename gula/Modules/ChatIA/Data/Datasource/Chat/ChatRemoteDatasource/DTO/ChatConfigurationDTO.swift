//
//  ChatConfigurationDTO.swift
//
//
//  Created by Axel Pérez Gaspar on 18/9/24.
//

import Foundation

struct ChatConfigurationDataDTO: Codable {
    let data: ChatConfigurationDTO
    let error: ChatErrorDTO?
}

struct ChatConfigurationDTO: Codable {
    let name: String
    let primaryColor: String
    let secondaryColor: String
    let firstMessage: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case primaryColor = "color1"
        case secondaryColor = "color2"
        case firstMessage = "first_message"
    }
}
