//
//  ChatDatasource.swift
//
//
//  Created by Axel Pérez Gaspar on 22/8/24.
//

import Foundation
import TripleA

@available(macOS 15.0, *)
final class ChatRemoteDatasource: ChatRemoteDatasourceProtocol {
    private let network: Network
    private let headers = ["X-API-ACCESS-TOKEN": Config.chatApiAccessToken,
                   "X-API-SIGNATURE-MATCH": Config.chatApiSignatureMatch]

    init(network: Network = Network(baseURL: "https://chatbot-staging.rudo.es/api")) {
        self.network = network
    }

    func createChat(of customerID: Int) async throws -> ChatDataDTO {
        let parameters = ["customer_id": customerID]

        let endpoint = Endpoint(path: "/chat/create",
                                httpMethod: .post,
                                parameters: parameters,
                                headers: headers)
        return try await network.load(endpoint: endpoint, of: ChatDataDTO.self)
    }

    func sendMessage(request: MessageRequestDTO) async throws -> MessageDataDTO {
        let body = try JSONEncoder().encode(request)
        let endpoint = Endpoint(path: "/chat/messages/send",
                                httpMethod: .post,
                                body: body,
                                headers: headers)
        return try await network.load(endpoint: endpoint, of: MessageDataDTO.self)
    }

    func getConfiguration(of customerID: Int) async throws -> ChatConfigurationDataDTO {
        let parameters = ["customer_id": customerID]
        let endpoint = Endpoint(path: "/chat/assistant/config",
                                httpMethod: .post,
                                parameters: parameters,
                                headers: headers)
        return try await network.load(endpoint: endpoint, of: ChatConfigurationDataDTO.self)
    }
}
