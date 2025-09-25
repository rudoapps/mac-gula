//
//  ProjectAgentRepository.swift
//
//
//  Created by Claude on 25/9/24.
//

import Foundation

final class ProjectAgentRepository: ProjectAgentRepositoryProtocol {
    private let mcpDatasource: ProjectAgentMCPDatasourceProtocol
    private let analyticsDatasource: ProjectAnalyticsDatasourceProtocol

    init(mcpDatasource: ProjectAgentMCPDatasourceProtocol, analyticsDatasource: ProjectAnalyticsDatasourceProtocol) {
        self.mcpDatasource = mcpDatasource
        self.analyticsDatasource = analyticsDatasource
    }

    func executeAction(_ action: ProjectAction, in project: Project) async throws -> AgentResponse {
        do {
            let executedAction = try await mcpDatasource.executeAction(action, in: project)
            let content = generateActionResponseContent(for: executedAction)
            let suggestions = generateSuggestions(for: action, in: project)

            return AgentResponse(
                content: content,
                actions: [executedAction],
                suggestions: suggestions
            )
        } catch {
            throw mapError(error)
        }
    }

    func analyzeProject(_ project: Project) async throws -> ProjectAnalysis {
        do {
            let details = try await analyticsDatasource.analyzeProject(project)
            let summary = generateAnalysisSummary(from: details, for: project)
            let recommendations = generateRecommendations(from: details, for: project)

            return ProjectAnalysis(
                project: project,
                summary: summary,
                details: details,
                recommendations: recommendations
            )
        } catch {
            throw mapError(error)
        }
    }

    func processAgentMessage(_ message: String, in project: Project?) async throws -> AgentResponse {
        do {
            let interpretation = interpretMessage(message)

            if let project = project {
                let analysis = try await analyzeProject(project)
                let contextualResponse = generateContextualResponse(
                    for: message,
                    interpretation: interpretation,
                    analysis: analysis
                )

                let suggestedActions = generateSuggestedActions(
                    for: interpretation,
                    in: project,
                    analysis: analysis
                )

                return AgentResponse(
                    content: contextualResponse,
                    actions: [],
                    suggestions: suggestedActions.map { $0.description }
                )
            } else {
                let genericResponse = generateGenericResponse(for: message, interpretation: interpretation)
                return AgentResponse(content: genericResponse)
            }
        } catch {
            throw mapError(error)
        }
    }
}

// MARK: - Private Helper Methods
private extension ProjectAgentRepository {
    func generateActionResponseContent(for executedAction: ExecutedAction) -> String {
        let action = executedAction.action
        let result = executedAction.result

        switch result {
        case .success(let output):
            return "✅ \(action.type.displayName) completado exitosamente.\n\n\(output)"
        case .failure(let error):
            return "❌ Error al ejecutar \(action.type.displayName):\n\n\(error)"
        case .partial(let output, let warning):
            return "⚠️ \(action.type.displayName) completado con advertencias:\n\n\(output)\n\n⚠️ Advertencia: \(warning)"
        }
    }

    func generateSuggestions(for action: ProjectAction, in project: Project) -> [String] {
        switch action.type {
        case .runBuild:
            return [
                "Ejecutar tests para validar el build",
                "Revisar warnings del compilador",
                "Considerar optimizar dependencias"
            ]
        case .analyzeCode:
            return [
                "Refactorizar código duplicado",
                "Actualizar documentación",
                "Revisar cobertura de tests"
            ]
        case .generateModule:
            return [
                "Agregar tests para el nuevo módulo",
                "Documentar la API del módulo",
                "Integrar con navegación existente"
            ]
        default:
            return []
        }
    }

    func generateAnalysisSummary(from details: AnalysisDetails, for project: Project) -> String {
        let projectType = project.type.displayName
        let files = details.fileCount
        let issues = details.issues.count
        let dependencies = details.dependencies.count

        var summary = "📊 **Análisis del proyecto \(project.name)**\n\n"
        summary += "**Tipo:** \(projectType)\n"
        summary += "**Archivos:** \(files)\n"
        summary += "**Dependencias:** \(dependencies)\n"

        if issues > 0 {
            let errors = details.issues.filter { $0.severity == .error }.count
            let warnings = details.issues.filter { $0.severity == .warning }.count
            summary += "**Issues:** \(errors) errores, \(warnings) warnings\n"
        } else {
            summary += "**Issues:** Sin problemas detectados ✅\n"
        }

        if let buildInfo = details.buildInfo {
            summary += "**Build:** \(buildInfo.canBuild ? "✅ OK" : "❌ Fallos")\n"
        }

        if let gitInfo = details.gitInfo, gitInfo.isRepo {
            summary += "**Git:** \(gitInfo.uncommittedChanges) cambios sin commit\n"
        }

        return summary
    }

    func generateRecommendations(from details: AnalysisDetails, for project: Project) -> [Recommendation] {
        var recommendations: [Recommendation] = []

        // Recommend build fixes
        if let buildInfo = details.buildInfo, !buildInfo.canBuild && !buildInfo.buildErrors.isEmpty {
            recommendations.append(
                Recommendation(
                    priority: .high,
                    title: "Corregir errores de compilación",
                    description: "El proyecto tiene \(buildInfo.buildErrors.count) errores que impiden la compilación.",
                    suggestedAction: ProjectAction(
                        type: .runBuild,
                        description: "Ejecutar build y mostrar errores"
                    )
                )
            )
        }

        // Recommend dependency updates
        let updatableDeps = details.dependencies.filter { $0.isUpdatable }
        if !updatableDeps.isEmpty {
            recommendations.append(
                Recommendation(
                    priority: .medium,
                    title: "Actualizar dependencias",
                    description: "\(updatableDeps.count) dependencias tienen actualizaciones disponibles.",
                    suggestedAction: ProjectAction(
                        type: .updateDependencies,
                        description: "Actualizar dependencias obsoletas"
                    )
                )
            )
        }

        // Recommend git commit if changes exist
        if let gitInfo = details.gitInfo, gitInfo.uncommittedChanges > 0 {
            recommendations.append(
                Recommendation(
                    priority: .low,
                    title: "Commit cambios pendientes",
                    description: "Hay \(gitInfo.uncommittedChanges) archivos con cambios sin commitear.",
                    suggestedAction: ProjectAction(
                        type: .gitCommit,
                        description: "Crear commit con cambios pendientes"
                    )
                )
            )
        }

        return recommendations
    }

    func interpretMessage(_ message: String) -> MessageInterpretation {
        let lowercased = message.lowercased()

        if lowercased.contains("analiz") || lowercased.contains("revis") {
            return .analyze
        } else if lowercased.contains("test") || lowercased.contains("prueb") {
            return .runTests
        } else if lowercased.contains("build") || lowercased.contains("compil") {
            return .build
        } else if lowercased.contains("generat") || lowercased.contains("crear") {
            return .generate
        } else if lowercased.contains("error") || lowercased.contains("fallo") || lowercased.contains("problema") {
            return .troubleshoot
        } else {
            return .general
        }
    }

    func generateContextualResponse(
        for message: String,
        interpretation: MessageInterpretation,
        analysis: ProjectAnalysis
    ) -> String {
        let projectName = analysis.project.name
        let projectType = analysis.project.type.displayName

        switch interpretation {
        case .analyze:
            return """
            📊 **Análisis del proyecto \(projectName)**

            \(analysis.summary)

            ¿Te gustaría que profundice en algún aspecto específico o ejecute alguna acción?
            """

        case .runTests:
            let hasTests = analysis.details.fileCount > 0 // Simplificado por ahora
            return hasTests ?
                "🧪 Proyecto \(projectName) (\(projectType)) listo para ejecutar tests. ¿Procedo?" :
                "⚠️ No he detectado archivos de test en este proyecto \(projectType). ¿Quieres que ayude a configurar tests?"

        case .build:
            if let buildInfo = analysis.details.buildInfo, buildInfo.canBuild {
                return "🔨 El proyecto \(projectName) está listo para build. ¿Ejecuto la compilación?"
            } else {
                return "❌ He detectado problemas que impedirían el build. ¿Quieres que los revise y corrija?"
            }

        case .generate:
            return """
            🛠️ Puedo ayudarte a generar contenido para tu proyecto \(projectType):

            • Módulos y componentes
            • Archivos de configuración
            • Tests automáticos
            • Documentación

            ¿Qué te gustaría generar?
            """

        case .troubleshoot:
            let issueCount = analysis.details.issues.count
            if issueCount > 0 {
                return "🔍 He encontrado \(issueCount) issues en el proyecto. ¿Quieres que los analice y proponga soluciones?"
            } else {
                return "✅ No he detectado problemas obvios en el proyecto. ¿Hay algo específico que esté fallando?"
            }

        case .general:
            return """
            👋 Soy tu asistente para el proyecto **\(projectName)** (\(projectType)).

            Puedo ayudarte con:
            • 📊 Análisis del proyecto
            • 🔨 Builds y compilación
            • 🧪 Ejecución de tests
            • 🛠️ Generación de código
            • 🔍 Resolución de problemas

            ¿En qué puedo ayudarte?
            """
        }
    }

    func generateGenericResponse(for message: String, interpretation: MessageInterpretation) -> String {
        switch interpretation {
        case .analyze:
            return "Para analizar un proyecto, primero necesito que abras uno desde la vista principal de Gula."
        case .runTests, .build:
            return "Para ejecutar acciones de desarrollo, necesito el contexto de un proyecto específico."
        case .generate:
            return "Puedo ayudarte a generar código cuando tengas un proyecto abierto. Los tipos soportados son: iOS, Android, Flutter y Python."
        case .troubleshoot:
            return "Para ayudarte con problemas específicos, necesito acceso al proyecto en cuestión."
        case .general:
            return """
            👋 Soy el asistente de desarrollo de Gula.

            Cuando abras un proyecto específico, podré ayudarte con:
            • Análisis de código
            • Builds y tests
            • Generación de módulos
            • Resolución de problemas

            ¡Abre un proyecto para empezar!
            """
        }
    }

    func generateSuggestedActions(
        for interpretation: MessageInterpretation,
        in project: Project,
        analysis: ProjectAnalysis
    ) -> [ProjectAction] {
        switch interpretation {
        case .analyze:
            return [
                ProjectAction(type: .runBuild, description: "Verificar que el proyecto compile"),
                ProjectAction(type: .runTests, description: "Ejecutar suite de tests")
            ]
        case .runTests:
            return [
                ProjectAction(type: .runTests, description: "Ejecutar todos los tests"),
                ProjectAction(type: .runBuild, description: "Build previo para asegurar compilación")
            ]
        case .build:
            return [
                ProjectAction(type: .runBuild, description: "Ejecutar build del proyecto")
            ]
        case .generate:
            return [
                ProjectAction(type: .generateModule, description: "Generar nuevo módulo"),
                ProjectAction(type: .createFile, description: "Crear archivo específico")
            ]
        case .troubleshoot:
            return analysis.recommendations.compactMap { $0.suggestedAction }
        case .general:
            return [
                ProjectAction(type: .analyzeCode, description: "Analizar proyecto completo")
            ]
        }
    }

    func mapError(_ error: Error) -> Error {
        if let error = error as? AppError {
            return error
        } else {
            return AppError.generalError
        }
    }

    enum MessageInterpretation {
        case analyze, runTests, build, generate, troubleshoot, general
    }
}