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
        return ChatUseCase(repository: repository, projectAgentRepository: makeProjectAgentRepository())
    }

    static func makeProjectAgentUseCase() -> ChatUseCase {
        let datasource = ChatRemoteDatasource()
        let localDatasource = ChatLocalDatasource()
        let errorHandler = ErrorHandlerManager()
        let repository = ChatRepository(datasource: datasource,
                                        localDatasource: localDatasource,
                                        errorHandlerManager: errorHandler)
        let projectAgentRepository = makeProjectAgentRepository()
        return ChatUseCase(repository: repository, projectAgentRepository: projectAgentRepository)
    }

    private static func makeProjectAgentRepository() -> ProjectAgentRepository {
        let mcpDatasource = ProjectAgentMCPDatasource()
        let analyticsDatasource = ProjectAnalyticsDatasource()
        return ProjectAgentRepository(mcpDatasource: mcpDatasource, analyticsDatasource: analyticsDatasource)
    }
}
