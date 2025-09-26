//
//  ActionLog.swift
//
//
//  Created by Claude on 25/9/24.
//

import Foundation

struct ActionLog: Identifiable, Equatable, Hashable {
    let id = UUID()
    let timestamp: Date
    let level: LogLevel
    let message: String

    enum LogLevel: String, CaseIterable {
        case info = "INFO"
        case warning = "WARN"
        case error = "ERROR"
        case success = "OK"
        case debug = "DEBUG"

        var systemImage: String {
            switch self {
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .success: return "checkmark.circle.fill"
            case .debug: return "ladybug.fill"
            }
        }

        var color: String {
            switch self {
            case .info: return "blue"
            case .warning: return "orange"
            case .error: return "red"
            case .success: return "green"
            case .debug: return "purple"
            }
        }
    }

    init(level: LogLevel, message: String) {
        self.timestamp = Date()
        self.level = level
        self.message = message
    }
}