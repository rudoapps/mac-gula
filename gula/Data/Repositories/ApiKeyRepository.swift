//
//  ApiKeyRepository.swift
//  Gula
//
//  Created by Claude on 21/10/25.
//

import Foundation

@available(macOS 15.0, *)
class ApiKeyRepository: ApiKeyRepositoryProtocol {
    private let remoteDataSource: ApiKeyRemoteDataSourceProtocol
    private let localDataSource: ApiKeyLocalDataSourceProtocol

    init(
        remoteDataSource: ApiKeyRemoteDataSourceProtocol,
        localDataSource: ApiKeyLocalDataSourceProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func getUserApiKey() async throws -> ApiKey {
        // Check if we have a valid cached API key
        if let cachedKey = localDataSource.getApiKey() {
            print("✅ Using cached API key (still valid within TTL)")
            return cachedKey
        }

        print("🔄 Fetching API key from remote (cache expired or not found)")

        // Fetch from remote
        let apiKey = try await remoteDataSource.fetchUserApiKey()

        // Cache it locally
        localDataSource.saveApiKey(apiKey)

        return apiKey
    }

    func clearApiKey() {
        localDataSource.clearApiKey()
        print("🗑️ API key cleared from cache")
    }
}
