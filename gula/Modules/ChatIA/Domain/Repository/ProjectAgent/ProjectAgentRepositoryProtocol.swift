//
//  ProjectAgentRepositoryProtocol.swift
//
//
//  Created by Claude on 25/9/24.
//

import Foundation

protocol ProjectAgentRepositoryProtocol {
    func executeAction(_ action: ProjectAction, in project: Project) async throws -> AgentResponse
    func analyzeProject(_ project: Project) async throws -> ProjectAnalysis
    func processAgentMessage(_ message: String, in project: Project?) async throws -> AgentResponse
}