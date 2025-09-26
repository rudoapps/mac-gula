//
//  ProjectAnalysis.swift
//
//
//  Created by Claude on 25/9/24.
//

import Foundation

struct ProjectAnalysis {
    let id = UUID()
    let project: Project
    let summary: String
    let details: AnalysisDetails
    let recommendations: [Recommendation]
    let analyzedAt: Date

    init(project: Project, summary: String, details: AnalysisDetails, recommendations: [Recommendation] = []) {
        self.project = project
        self.summary = summary
        self.details = details
        self.recommendations = recommendations
        self.analyzedAt = Date()
    }
}

struct AnalysisDetails {
    let fileCount: Int
    let codeLines: Int
    let dependencies: [Dependency]
    let issues: [Issue]
    let buildInfo: BuildInfo?
    let gitInfo: GitInfo?

    struct Dependency {
        let name: String
        let version: String?
        let isUpdatable: Bool
        let source: DependencySource

        enum DependencySource {
            case spm, cocoapods, npm, pip, gradle
        }
    }

    struct Issue {
        let severity: Severity
        let message: String
        let file: String?
        let line: Int?

        enum Severity: String, CaseIterable {
            case error, warning, info

            var systemImage: String {
                switch self {
                case .error: return "xmark.circle.fill"
                case .warning: return "exclamationmark.triangle.fill"
                case .info: return "info.circle.fill"
                }
            }

            var color: String {
                switch self {
                case .error: return "red"
                case .warning: return "orange"
                case .info: return "blue"
                }
            }
        }
    }

    struct BuildInfo {
        let canBuild: Bool
        let lastBuildTime: Date?
        let buildErrors: [String]
        let buildWarnings: [String]
    }

    struct GitInfo {
        let isRepo: Bool
        let branch: String?
        let uncommittedChanges: Int
        let lastCommit: Date?
        let remoteUrl: String?
    }
}

struct Recommendation {
    let id = UUID()
    let priority: Priority
    let title: String
    let description: String
    let suggestedAction: ProjectAction?

    enum Priority: String, CaseIterable {
        case high, medium, low

        var displayName: String {
            switch self {
            case .high: return "Alta"
            case .medium: return "Media"
            case .low: return "Baja"
            }
        }

        var color: String {
            switch self {
            case .high: return "red"
            case .medium: return "orange"
            case .low: return "blue"
            }
        }

        var systemImage: String {
            switch self {
            case .high: return "exclamationmark.triangle.fill"
            case .medium: return "exclamationmark.circle.fill"
            case .low: return "info.circle.fill"
            }
        }
    }
}

extension ProjectAnalysis: Identifiable {}
extension Recommendation: Identifiable {}