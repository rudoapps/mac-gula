//
//  ChatFloatingButtonBuilder.swift
//  
//
//  Created by Axel Pérez Gaspar on 18/9/24.
//

import SwiftUI

@available(macOS 15.0, *)
final class ChatFloatingButtonBuilder {
    static func build(with appearance: ChatAppearance) -> ChatFloatingButton {
        let datasource = ChatRemoteDatasource()
        let localDatasource = ChatLocalDatasource()
        let errorHandler = ErrorHandlerManager()
        let repository = ChatRepository(datasource: datasource,
                                        localDatasource: localDatasource,
                                        errorHandlerManager: errorHandler)
        let projectAgentRepository = makeProjectAgentRepository()
        let useCase = ChatUseCase(repository: repository, projectAgentRepository: projectAgentRepository)
        let router = ChatFloatingButtonRouter()
        let viewModel = ChatFloatingButtonViewModel(useCase: useCase,
                                                    appearance: appearance,
                                                    router: router)
        return ChatFloatingButton(viewModel: viewModel)
    }

    private static func makeProjectAgentRepository() -> ProjectAgentRepository {
        let mcpDatasource = ProjectAgentMCPDatasource()
        let analyticsDatasource = ProjectAnalyticsDatasource()
        return ProjectAgentRepository(mcpDatasource: mcpDatasource, analyticsDatasource: analyticsDatasource)
    }
}
