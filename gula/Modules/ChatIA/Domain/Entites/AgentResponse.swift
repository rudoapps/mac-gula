//
//  AgentResponse.swift
//
//
//  Created by Claude on 25/9/24.
//

import Foundation

struct AgentResponse {
    let id = UUID()
    let content: String
    let actions: [ExecutedAction]
    let suggestions: [String]
    let timestamp: Date

    init(content: String, actions: [ExecutedAction] = [], suggestions: [String] = []) {
        self.content = content
        self.actions = actions
        self.suggestions = suggestions
        self.timestamp = Date()
    }
}

struct ExecutedAction {
    let id = UUID()
    let action: ProjectAction
    let result: ActionResult
    let executedAt: Date

    enum ActionResult {
        case success(output: String)
        case failure(error: String)
        case partial(output: String, warning: String)

        var isSuccess: Bool {
            switch self {
            case .success, .partial: return true
            case .failure: return false
            }
        }

        var output: String {
            switch self {
            case .success(let output), .partial(let output, _): return output
            case .failure(let error): return error
            }
        }

        var statusIcon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .failure: return "xmark.circle.fill"
            case .partial: return "exclamationmark.triangle.fill"
            }
        }

        var statusColor: String {
            switch self {
            case .success: return "green"
            case .failure: return "red"
            case .partial: return "orange"
            }
        }
    }

    init(action: ProjectAction, result: ActionResult) {
        self.action = action
        self.result = result
        self.executedAt = Date()
    }
}

extension AgentResponse: Identifiable {}
extension ExecutedAction: Identifiable {}