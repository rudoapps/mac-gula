//
//  ChatConfigurationCacheDTO.swift
//  chatbot-ia
//
//  Created by Axel Pérez Gaspar on 19/9/24.
//

struct ChatConfigurationCacheDTO: Codable {
    let customerID: Int
    let primaryColor: String
    let secondaryColor: String
    let textColor: String
    let firstMessage: String
}
