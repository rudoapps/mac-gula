//
//  ProjectAction.swift
//
//
//  Created by Claude on 25/9/24.
//

import Foundation

struct ProjectAction {
    let id = UUID()
    let type: ActionType
    let parameters: [String: Any]
    let description: String

    enum ActionType: String, CaseIterable {
        case analyzeCode = "analyze_code"
        case generateModule = "generate_module"
        case runTests = "run_tests"
        case runBuild = "run_build"
        case updateDependencies = "update_dependencies"
        case createFile = "create_file"
        case refactorCode = "refactor_code"
        case gitCommit = "git_commit"
        case openInXcode = "open_in_xcode"
        case createReadme = "create_readme"

        var displayName: String {
            switch self {
            case .analyzeCode: return "Analizar Código"
            case .generateModule: return "Generar Módulo"
            case .runTests: return "Ejecutar Tests"
            case .runBuild: return "Ejecutar Build"
            case .updateDependencies: return "Actualizar Dependencias"
            case .createFile: return "Crear Archivo"
            case .refactorCode: return "Refactorizar"
            case .gitCommit: return "Hacer Commit"
            case .openInXcode: return "Abrir en Xcode"
            case .createReadme: return "Crear README"
            }
        }

        var systemImage: String {
            switch self {
            case .analyzeCode: return "doc.text.magnifyingglass"
            case .generateModule: return "plus.rectangle.on.folder"
            case .runTests: return "checkmark.circle"
            case .runBuild: return "hammer"
            case .updateDependencies: return "arrow.clockwise"
            case .createFile: return "doc.badge.plus"
            case .refactorCode: return "wand.and.rays"
            case .gitCommit: return "externaldrive.badge.plus"
            case .openInXcode: return "xmark.app"
            case .createReadme: return "doc.text"
            }
        }
    }

    init(type: ActionType, parameters: [String: Any] = [:], description: String) {
        self.type = type
        self.parameters = parameters
        self.description = description
    }
}

extension ProjectAction: Identifiable, Hashable {
    static func == (lhs: ProjectAction, rhs: ProjectAction) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}