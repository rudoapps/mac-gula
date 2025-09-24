//
//  ChatLocalDatasource.swift
//  chatbot-ia
//
//  Created by Axel Pérez Gaspar on 19/9/24.
//

import Foundation

final class ChatLocalDatasource: ChatLocalDatasourceProtocol {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveConfiguration(_ configuration: ChatConfigurationCacheDTO) throws {
        do {
            let data = try JSONEncoder().encode(configuration)
            userDefaults.set(data, forKey: "configuration_\(configuration.customerID)")
        } catch {
            throw error
        }
    }

    func getConfiguration(of customerID: Int) throws -> ChatConfigurationCacheDTO? {
        if let data = userDefaults.data(forKey: "configuration_\(customerID)") {
            do {
                let value = try JSONDecoder().decode(ChatConfigurationCacheDTO.self, from: data)
                return value
            } catch {
                throw error
            }
        } else {
            return nil
        }
    }
}
