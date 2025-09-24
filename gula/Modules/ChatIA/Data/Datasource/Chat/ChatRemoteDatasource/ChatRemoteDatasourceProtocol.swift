//
//  ChatRemoteDatasourceProtocol.swift
//
//
//  Created by Axel Pérez Gaspar on 12/8/24.
//

import Foundation

protocol ChatRemoteDatasourceProtocol {
    func createChat(of customerID: Int) async throws -> ChatDataDTO
    func sendMessage(request: MessageRequestDTO) async throws -> MessageDataDTO
    func getConfiguration(of customerID: Int) async throws -> ChatConfigurationDataDTO
}
