//
//  ApiKeyLocalDataSourceProtocol.swift
//  Gula
//
//  Created by Claude on 21/10/25.
//

import Foundation

/// Protocol defining local data source operations for API keys
protocol ApiKeyLocalDataSourceProtocol {
    /// Saves the API key locally with a timestamp
    /// - Parameter apiKey: The API key to save
    func saveApiKey(_ apiKey: ApiKey)

    /// Retrieves the locally stored API key if it's still valid (within TTL)
    /// - Returns: The stored API key if valid, nil if expired or not found
    func getApiKey() -> ApiKey?

    /// Clears the stored API key and its timestamp
    func clearApiKey()

    /// Checks if the stored API key is still valid based on TTL
    /// - Returns: true if key exists and is within TTL, false otherwise
    func isApiKeyValid() -> Bool
}
