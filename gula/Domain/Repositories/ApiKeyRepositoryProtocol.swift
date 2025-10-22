//
//  ApiKeyRepositoryProtocol.swift
//  Gula
//
//  Created by Claude on 21/10/25.
//

import Foundation

/// Protocol defining the contract for API key repository operations
protocol ApiKeyRepositoryProtocol {
    /// Fetches the API key for the authenticated user
    /// This method handles TTL logic internally:
    /// - Returns cached key if still valid (within TTL)
    /// - Fetches from remote if expired or not cached
    /// - Returns: The user's API key
    /// - Throws: Error if the request fails or user is not authenticated
    func getUserApiKey() async throws -> ApiKey

    /// Clears the stored API key and its TTL
    func clearApiKey()
}
