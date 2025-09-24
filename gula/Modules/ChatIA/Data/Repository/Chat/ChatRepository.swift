//
//  ChatRepository.swift
//
//
//  Created by Axel Pérez Gaspar on 12/8/24.
//

import Foundation
import TripleA

final class ChatRepository: ChatRepositoryProtocol {
    private let datasource: ChatRemoteDatasourceProtocol
    private let errorHandlerManager: ErrorHandlerProtocol
    private let localDatasource: ChatLocalDatasourceProtocol

    init(datasource: ChatRemoteDatasourceProtocol,
         localDatasource: ChatLocalDatasourceProtocol,
         errorHandlerManager: ErrorHandlerProtocol) {
        self.datasource = datasource
        self.localDatasource = localDatasource
        self.errorHandlerManager = errorHandlerManager
    }

    func createChat(of customerID: Int) async throws -> Int {
        do {
            let response = try await datasource.createChat(of: customerID)
            return response.data.id
        } catch {
            throw errorHandlerManager.handle(error)
        }
    }

    func sendMessage(request: MessageRequest) async throws -> Message {
        do {
            let response = try await datasource.sendMessage(request: request.toDTO())
            if let message = response.data.first {
                return message.toDomain()
            } else {
                throw NetworkError.invalidResponse
            }
        } catch {
            throw errorHandlerManager.handle(error)
        }
    }

    func getConfiguration(of customerID: Int) async throws -> ChatConfiguration {
        do {
            if let cacheConfiguration = try localDatasource.getConfiguration(of: customerID) {
                return cacheConfiguration.toDomain()
            } else {
                let response = try await datasource.getConfiguration(of: customerID)
                try localDatasource.saveConfiguration(response.data.toCache(with: customerID))
                return response.data.toDomain(with: customerID)
            }
        } catch {
            throw errorHandlerManager.handle(error)
        }
    }
}

fileprivate extension MessageRequest {
    func toDTO() -> MessageRequestDTO {
        MessageRequestDTO(chatID: self.chatID,
                          content: self.message,
                          assistantID: 1)
    }
}

fileprivate extension MessageDTO {
    func toDomain() -> Message {
        Message(self.value,
                type: Message.MessageType(rawValue: self.role) ?? .bot)
    }
}

fileprivate extension ChatConfigurationDTO {
    func toDomain(with customerID: Int) -> ChatConfiguration {
        ChatConfiguration(customerID: customerID,
                          primaryColor: self.primaryColor,
                          secondaryColor: self.secondaryColor,
                          textColor: "#121B29",
                          firstMessage: self.firstMessage)
    }

    func toCache(with customerID: Int) -> ChatConfigurationCacheDTO {
        ChatConfigurationCacheDTO(customerID: customerID,
                                  primaryColor: self.primaryColor,
                                  secondaryColor: self.secondaryColor,
                                  textColor: "#121B29",
                                  firstMessage: self.firstMessage)
    }
}

fileprivate extension ChatConfigurationCacheDTO {
    func toDomain() -> ChatConfiguration {
        ChatConfiguration(customerID: self.customerID,
                          primaryColor: self.primaryColor,
                          secondaryColor: self.secondaryColor,
                          textColor: self.textColor,
                          firstMessage: self.firstMessage)
    }
}
