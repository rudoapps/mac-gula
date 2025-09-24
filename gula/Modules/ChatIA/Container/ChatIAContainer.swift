//
//  ChatIAContainer.swift
//  Gula
//
//  Created by Eduard on 19/8/25.
//

import Foundation

@available(macOS 15.0, *)
class ChatIAContainer {
    static func makeUseCase() -> ChatUseCase {
        let datasource = ChatRemoteDatasource()
        let localDatasource = ChatLocalDatasource()
        let errorHandler = ErrorHandlerManager()
        let repository = ChatRepository(datasource: datasource,
                                        localDatasource: localDatasource,
                                        errorHandlerManager: errorHandler)
        return ChatUseCase(repository: repository)
    }
}
