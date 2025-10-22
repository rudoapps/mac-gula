//
//  ApiKeyRemoteDataSourceProtocol.swift
//  Gula
//
//  Created by Claude on 21/10/25.
//

import Foundation

/// Protocol defining remote data source operations for API keys
protocol ApiKeyRemoteDataSourceProtocol {
    /// Fetches the API key from the remote microservice
    /// Requires user to be authenticated
    /// - Returns: The user's API key from the server
    /// - Throws: Error if request fails or user is not authenticated
    func fetchUserApiKey() async throws -> ApiKey
}
