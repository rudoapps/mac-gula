//
//  ProjectAgentMCPDatasourceProtocol.swift
//
//
//  Created by Claude on 25/9/24.
//

import Foundation

protocol ProjectAgentMCPDatasourceProtocol {
    func executeAction(_ action: ProjectAction, in project: Project) async throws -> ExecutedAction
}