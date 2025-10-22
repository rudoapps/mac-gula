//
//  ApiKeyResponse.swift
//  Gula
//
//  Created by Claude on 21/10/25.
//

import Foundation

/// Response model from the microservice API
struct ApiKeyResponse: Codable {
    let apiKey: String

    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
    }
}
