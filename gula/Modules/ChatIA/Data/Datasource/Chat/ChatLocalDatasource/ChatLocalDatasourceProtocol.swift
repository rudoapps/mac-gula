//
//  ChatLocalDatasourceProtocol.swift
//  chatbot-ia
//
//  Created by Axel Pérez Gaspar on 19/9/24.
//

protocol ChatLocalDatasourceProtocol {
    func saveConfiguration(_ configuration: ChatConfigurationCacheDTO) throws
    func getConfiguration(of customerID: Int) throws -> ChatConfigurationCacheDTO?
}
