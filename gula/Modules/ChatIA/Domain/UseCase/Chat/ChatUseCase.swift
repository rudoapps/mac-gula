//
//  ChatUseCase.swift
//
//
//  Created by Axel Pérez Gaspar on 22/8/24.
//

import Foundation

final class ChatUseCase: ChatUseCaseProtocol {
    private let repository: ChatRepositoryProtocol
    private let projectAgentRepository: ProjectAgentRepositoryProtocol

    init(repository: ChatRepositoryProtocol, projectAgentRepository: ProjectAgentRepositoryProtocol) {
        self.repository = repository
        self.projectAgentRepository = projectAgentRepository
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

    // MARK: - Project Agent Capabilities

    func executeProjectAction(_ action: ProjectAction, in project: Project) async throws -> AgentResponse {
        do {
            return try await projectAgentRepository.executeAction(action, in: project)
        } catch {
            throw handle(this: error)
        }
    }

    func analyzeProject(_ project: Project) async throws -> ProjectAnalysis {
        do {
            return try await projectAgentRepository.analyzeProject(project)
        } catch {
            throw handle(this: error)
        }
    }

    func sendAgentMessage(_ message: String, in project: Project?) async throws -> AgentResponse {
        do {
            return try await projectAgentRepository.processAgentMessage(message, in: project)
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
