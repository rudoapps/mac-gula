//
//  GetUserApiKeyUseCase.swift
//  Gula
//
//  Created by Claude on 21/10/25.
//

import Foundation

/// Protocol defining the contract for the GetUserApiKey use case
protocol GetUserApiKeyUseCaseProtocol {
    /// Executes the use case to get the user's API key
    /// - Returns: The user's API key (from cache if valid, otherwise fetches from remote)
    func execute() async throws -> ApiKey

    /// Clears the stored API key
    func clearApiKey()
}

/// Use case for retrieving the user's API key
class GetUserApiKeyUseCase: GetUserApiKeyUseCaseProtocol {
    private let repository: ApiKeyRepositoryProtocol

    init(repository: ApiKeyRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> ApiKey {
        // The repository handles TTL logic internally
        // It will return cached key if valid, or fetch from remote if expired/missing
        return try await repository.getUserApiKey()
    }

    func clearApiKey() {
        repository.clearApiKey()
    }
}
