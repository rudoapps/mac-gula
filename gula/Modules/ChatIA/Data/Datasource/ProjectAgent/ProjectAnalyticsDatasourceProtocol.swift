//
//  ProjectAnalyticsDatasourceProtocol.swift
//
//
//  Created by Claude on 25/9/24.
//

import Foundation

protocol ProjectAnalyticsDatasourceProtocol {
    func analyzeProject(_ project: Project) async throws -> AnalysisDetails
}