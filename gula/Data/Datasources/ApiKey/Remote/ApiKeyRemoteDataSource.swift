//
//  ApiKeyRemoteDataSource.swift
//  Gula
//
//  Created by Claude on 21/10/25.
//

import Foundation
import TripleA

@available(macOS 15.0, *)
class ApiKeyRemoteDataSource: ApiKeyRemoteDataSourceProtocol {
    private let network: Network

    init(network: Network) {
        self.network = network
    }

    func fetchUserApiKey() async throws -> ApiKey {
        // Call the microservice endpoint to get the API key
        let endpoint = Endpoint(
            path: "api/gula/api-key/mine",
            httpMethod: .get
        )

        let response: ApiKeyResponse = try await network.loadAuthorized(this: endpoint, of: ApiKeyResponse.self)

        return ApiKey(key: response.apiKey)
    }
}
