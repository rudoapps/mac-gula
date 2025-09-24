//
//  ChatUseCase.swift
//
//
//  Created by Axel Pérez Gaspar on 22/8/24.
//

import Foundation

final class ChatUseCase: ChatUseCaseProtocol {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func createChat(of customerID: Int) async throws -> Int {
        do {
            return try await repository.createChat(of: customerID)
        } catch {
            throw handle(this: error)
        }
    }

    func sendMessage(request: MessageRequest) async throws -> Message {
        do {
            return try await repository.sendMessage(request: request)
        } catch {
            throw handle(this: error)
        }
    }

    func getConfiguration(of customerID: Int) async throws -> ChatConfiguration {
        do {
            return try await repository.getConfiguration(of: customerID)
        } catch {
            throw handle(this: error)
        }
    }
}

extension ChatUseCase {
    func handle(this error: Error) -> Error {
        if let error = error as? AppError {
            return error
        } else {
            return AppError.generalError
        }
    }
}
