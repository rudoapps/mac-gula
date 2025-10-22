//
//  ApiKeyLocalDataSource.swift
//  Gula
//
//  Created by Claude on 21/10/25.
//

import Foundation

class ApiKeyLocalDataSource: ApiKeyLocalDataSourceProtocol {
    private let userDefaults: UserDefaults
    private let apiKeyKey = "gula_user_api_key"
    private let timestampKey = "gula_api_key_timestamp"

    // TTL: 24 hours (API keys are long-lived but we refresh daily)
    private let timeToLive: TimeInterval = 24 * 60 * 60

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveApiKey(_ apiKey: ApiKey) {
        userDefaults.set(apiKey.key, forKey: apiKeyKey)
        userDefaults.set(Date().timeIntervalSince1970, forKey: timestampKey)
    }

    func getApiKey() -> ApiKey? {
        guard isApiKeyValid(),
              let keyString = userDefaults.string(forKey: apiKeyKey) else {
            return nil
        }

        return ApiKey(key: keyString)
    }

    func clearApiKey() {
        userDefaults.removeObject(forKey: apiKeyKey)
        userDefaults.removeObject(forKey: timestampKey)
    }

    func isApiKeyValid() -> Bool {
        guard let timestamp = userDefaults.object(forKey: timestampKey) as? TimeInterval else {
            return false
        }

        let savedDate = Date(timeIntervalSince1970: timestamp)
        let now = Date()
        let elapsed = now.timeIntervalSince(savedDate)

        return elapsed < timeToLive
    }
}
