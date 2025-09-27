//
//  ChatViewModel.swift
//
//
//  Created by Jorge on 23/7/24.
//

import Foundation

@Observable
final class ChatViewModel {
    private let useCase: ChatUseCaseProtocol
    private let router: ChatRouter
    private var messageToSend: String = ""
    private var chatID: Int?
    private var customerID: Int
    private var project: Project?

    var messages: [Message] = []
    var newMessage: String = ""
    var configuration: ChatConfiguration?
    var isProjectAgent: Bool { project != nil }
    var currentAction: ExecutingAction?
    var actionProgress: Double = 0.0
    var suggestedActionButtons: [ProjectAction] = []
    var actionLogs: [ActionLog] = []
    var showingLogsWindow = false

    struct ExecutingAction {
        let action: ProjectAction
        let status: ActionStatus
        let progressMessage: String
        let startTime: Date

        enum ActionStatus: Equatable {
            case preparing
            case executing
            case finishing
            case completed
            case failed(String)

            var displayMessage: String {
                switch self {
                case .preparing: return "Preparando..."
                case .executing: return "Ejecutando..."
                case .finishing: return "Finalizando..."
                case .completed: return "Completado"
                case .failed(let error): return "Error: \(error)"
                }
            }

            var systemImage: String {
                switch self {
                case .preparing: return "clock"
                case .executing: return "gear.badge.questionmark"
                case .finishing: return "checkmark.circle"
                case .completed: return "checkmark.circle.fill"
                case .failed: return "xmark.circle.fill"
                }
            }

            var color: String {
                switch self {
                case .preparing: return "blue"
                case .executing: return "orange"
                case .finishing: return "green"
                case .completed: return "green"
                case .failed: return "red"
                }
            }
        }
    }

    init(useCase: ChatUseCaseProtocol, customerID: Int, router: ChatRouter) {
        self.useCase = useCase
        self.customerID = customerID
        self.router = router
        self.project = nil
    }

    init(useCase: ChatUseCaseProtocol, customerID: Int, project: Project, router: ChatRouter) {
        self.useCase = useCase
        self.customerID = customerID
        self.project = project
        self.router = router

        // Auto-populate suggested actions for project agent
        Task { @MainActor in
            setupProjectAgent()
        }
    }

    @MainActor
    private func setupProjectAgent() {
        guard let project = project else { return }

        // Add welcome message
        let welcomeMessage = Message("👋 ¡Hola! Soy tu asistente para el proyecto **\(project.name)** (\(project.type.displayName)).\n\n¿En qué puedo ayudarte?", type: .bot)
        messages.append(welcomeMessage)

        // Show initial suggested actions
        suggestedActionButtons = generateSuggestedActionsForContext()
    }
}

@MainActor
extension ChatViewModel {
    func sendMessage() {
        messageToSend = newMessage
        if let lastMessage = messages.last,
           lastMessage.type == .error {
            messages.removeLast()
        }
        manageNewMessage()
        newMessage = ""
    }
    
    func resendMessage() {
        messages.removeLast(2)
        manageNewMessage()
    }
    
    func getConfiguration() {
        Task {
            do {
                configuration = try await useCase.getConfiguration(of: customerID)
            } catch {
                handle(this: error)
            }
        }
    }

    func checkIfCanSendMessage() {
        if !newMessage.isEmpty {
            sendMessage()
        }
    }

    func executeAction(_ action: ProjectAction) {
        print("🔧 [DEBUG] executeAction called with: \(action.type.displayName)")
        guard let project = project else {
            print("❌ [DEBUG] No project available for action execution")
            return
        }
        print("✅ [DEBUG] Project found: \(project.name) (\(project.type.displayName))")

        Task {
            do {
                print("🚀 [DEBUG] Starting action execution...")
                // Start action execution with visual feedback
                await startActionExecution(action)

                print("📡 [DEBUG] Calling useCase.executeProjectAction...")
                // Execute the actual action
                let agentResponse = try await useCase.executeProjectAction(action, in: project)

                // Complete action execution
                await completeActionExecution(agentResponse)

            } catch {
                await failActionExecution(error)
            }
        }
    }

    private func startActionExecution(_ action: ProjectAction) async {
        print("⚙️ [DEBUG] startActionExecution called")
        // Clear previous logs
        clearLogs()
        print("📝 [DEBUG] Logs cleared, adding initial logs...")

        addLog(.info, message: "🚀 Iniciando \(action.type.displayName)")
        addLog(.debug, message: "Acción: \(action.description)")

        currentAction = ExecutingAction(
            action: action,
            status: .preparing,
            progressMessage: "Iniciando \(action.type.displayName)...",
            startTime: Date()
        )
        actionProgress = 0.1

        // Add preparation message to chat
        let preparingMessage = Message("🔄 \(action.type.displayName): \(action.description)", type: .loading)
        messages.append(preparingMessage)

        addLog(.info, message: "Preparando entorno de ejecución...")

        // Simulate preparation time
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        addLog(.info, message: "Entorno preparado correctamente")
        addLog(.info, message: "Iniciando ejecución...")

        // Update to executing
        currentAction = ExecutingAction(
            action: action,
            status: .executing,
            progressMessage: "Ejecutando \(action.type.displayName)...",
            startTime: currentAction?.startTime ?? Date()
        )
        actionProgress = 0.3
    }

    private func completeActionExecution(_ agentResponse: AgentResponse) async {
        addLog(.info, message: "Procesando resultados...")

        // Update to finishing
        currentAction = ExecutingAction(
            action: currentAction?.action ?? ProjectAction(type: .analyzeCode, description: ""),
            status: .finishing,
            progressMessage: "Finalizando...",
            startTime: currentAction?.startTime ?? Date()
        )
        actionProgress = 0.8

        // Create logs specific to this execution
        var executionLogs: [ActionLog] = []

        // Log execution results
        for executedAction in agentResponse.actions {
            let actionName = executedAction.action.type.displayName
            switch executedAction.result {
            case .success(let output):
                let successLog = ActionLog(level: .success, message: "✅ \(actionName) completado exitosamente")
                addLog(.success, message: successLog.message)
                executionLogs.append(successLog)

                if !output.isEmpty {
                    let outputLog = ActionLog(level: .debug, message: "Output: \(String(output.prefix(200)))")
                    addLog(.debug, message: outputLog.message)
                    executionLogs.append(outputLog)
                }
            case .failure(let error):
                let errorLog = ActionLog(level: .error, message: "❌ \(actionName) falló: \(error)")
                addLog(.error, message: errorLog.message)
                executionLogs.append(errorLog)
            case .partial(let output, let warning):
                let warningLog = ActionLog(level: .warning, message: "⚠️ \(actionName) completado con advertencias")
                addLog(.warning, message: warningLog.message)
                executionLogs.append(warningLog)

                if !output.isEmpty {
                    let outputLog = ActionLog(level: .debug, message: "Output: \(String(output.prefix(200)))")
                    addLog(.debug, message: outputLog.message)
                    executionLogs.append(outputLog)
                }

                let warningDetailLog = ActionLog(level: .warning, message: "Warning: \(warning)")
                addLog(.warning, message: warningDetailLog.message)
                executionLogs.append(warningDetailLog)
            }
        }

        // Add execution time log
        let executionTime = Date().timeIntervalSince(currentAction?.startTime ?? Date())
        let completionLog = ActionLog(level: .success, message: "🎉 Acción completada en \(String(format: "%.1f", executionTime))s")
        addLog(.success, message: completionLog.message)
        executionLogs.append(completionLog)

        // Remove loading message
        if let lastMessage = messages.last, lastMessage.type == .loading {
            messages.removeLast()
        }

        // Add assistant response with specific logs
        let assistantMessage = createAssistantMessage(for: agentResponse, with: executionLogs)
        messages.append(assistantMessage)

        // Complete the action
        actionProgress = 1.0
        currentAction = ExecutingAction(
            action: currentAction?.action ?? ProjectAction(type: .analyzeCode, description: ""),
            status: .completed,
            progressMessage: "Completado exitosamente",
            startTime: currentAction?.startTime ?? Date()
        )

        // Clear action state after delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        currentAction = nil
        actionProgress = 0.0
    }

    private func failActionExecution(_ error: Error) async {
        currentAction = ExecutingAction(
            action: currentAction?.action ?? ProjectAction(type: .analyzeCode, description: ""),
            status: .failed(error.localizedDescription),
            progressMessage: "Error: \(error.localizedDescription)",
            startTime: currentAction?.startTime ?? Date()
        )
        actionProgress = 0.0

        // Remove loading message and add error
        if let lastMessage = messages.last, lastMessage.type == .loading {
            messages.removeLast()
        }

        let errorMessage = Message("❌ Error ejecutando acción: \(error.localizedDescription)", type: .error)
        messages.append(errorMessage)

        // Clear action state after delay
        try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        currentAction = nil
    }

    private func createResultMessage(for executedAction: ExecutedAction) -> Message {
        let action = executedAction.action
        let result = executedAction.result

        switch result {
        case .success(let output):
            let cleanSummary = createCleanSummary(from: output, for: action)
            return Message("✅ \(action.type.displayName) completado exitosamente.\n\n\(cleanSummary)", type: .bot)
        case .failure(let error):
            let cleanError = createCleanErrorSummary(from: error, for: action)
            return Message("❌ \(action.type.displayName) falló.\n\n\(cleanError)", type: .error)
        case .partial(let output, let warning):
            let cleanSummary = createCleanSummary(from: output, for: action)
            return Message("⚠️ \(action.type.displayName) completado con advertencias.\n\n\(cleanSummary)", type: .warning)
        }
    }

    private func createCleanSummary(from output: String, for action: ProjectAction) -> String {
        switch action.type {
        case .runBuild:
            return output.contains("succeeded") ? "🔨 Compilación exitosa en \(extractBuildTime(from: output))" : "📊 Build completado"
        case .runTests:
            return extractTestSummary(from: output)
        case .analyzeCode:
            return "📊 Análisis completado - Ver logs para detalles"
        case .generateModule:
            return "🛠️ Módulo generado correctamente"
        case .updateDependencies:
            return "📦 Dependencias actualizadas"
        case .createFile:
            return "📄 Archivo creado"
        case .gitCommit:
            return "📝 Commit realizado"
        case .openInXcode:
            return "📱 Proyecto abierto en Xcode"
        case .createReadme:
            return "📚 README.md creado"
        default:
            return "✅ Operación completada"
        }
    }

    private func createCleanErrorSummary(from error: String, for action: ProjectAction) -> String {
        // Extract key error without full log dump
        let lines = error.components(separatedBy: .newlines)
        let keyError = lines.first { line in
            line.lowercased().contains("error") || line.lowercased().contains("failed")
        } ?? lines.first ?? "Error desconocido"

        return String(keyError.prefix(100)) + (keyError.count > 100 ? "..." : "")
    }

    private func extractBuildTime(from output: String) -> String {
        if let range = output.range(of: #"\d+\.\d+\s*seconds"#, options: .regularExpression) {
            return String(output[range])
        }
        return "unos segundos"
    }

    private func createAssistantMessage(for agentResponse: AgentResponse, with logs: [ActionLog]? = nil) -> Message {
        let executedActions = agentResponse.actions

        if executedActions.isEmpty {
            // Pure conversation response
            return Message(agentResponse.content, type: .bot, logs: logs)
        }

        // Generate contextual response based on executed actions
        let successfulActions = executedActions.filter { $0.result.isSuccess }
        let failedActions = executedActions.filter { !$0.result.isSuccess }

        var assistantResponse = ""

        if !failedActions.isEmpty {
            assistantResponse = generateFailureResponse(for: failedActions)
        } else if !successfulActions.isEmpty {
            assistantResponse = generateSuccessResponse(for: successfulActions)
        } else {
            assistantResponse = "He procesado tu solicitud. Revisa los logs para más detalles."
        }

        // Add suggestions if any
        if !agentResponse.suggestions.isEmpty {
            assistantResponse += "\n\n💡 Te recomiendo: \(agentResponse.suggestions.first ?? "")"
        }

        return Message(assistantResponse, type: .bot, logs: logs)
    }

    private func generateSuccessResponse(for actions: [ExecutedAction]) -> String {
        let action = actions.first?.action

        switch action?.type {
        case .runBuild:
            return "¡Perfecto! Tu proyecto compiló sin problemas. Todo está listo para continuar desarrollando."
        case .runTests:
            return "Excelente, los tests se ejecutaron correctamente. Tu código está funcionando como esperado."
        case .analyzeCode:
            return "He analizado tu proyecto. Encontrarás un resumen detallado en los logs si necesitas profundizar."
        case .generateModule:
            return "¡Listo! He creado el nuevo módulo. Ya puedes empezar a trabajar en él."
        case .updateDependencies:
            return "Dependencias actualizadas exitosamente. Tu proyecto está ahora con las últimas versiones."
        case .gitCommit:
            return "Cambios guardados en Git. Tu trabajo está seguro en el historial del proyecto."
        case .createFile:
            return "Archivo creado correctamente. Puedes encontrarlo en tu proyecto."
        case .createReadme:
            return "README generado. Ahora tu proyecto tiene documentación básica."
        case .openInXcode:
            return "Proyecto abierto en Xcode. ¡A programar se ha dicho!"
        default:
            return "¡Hecho! La operación se completó exitosamente."
        }
    }

    private func generateFailureResponse(for actions: [ExecutedAction]) -> String {
        let action = actions.first?.action

        switch action?.type {
        case .runBuild:
            return "Ups, hay algunos errores que impiden la compilación. Revisa los logs para ver qué necesita arreglarse."
        case .runTests:
            return "Algunos tests no pasaron. Los logs te mostrarán exactamente cuáles necesitan atención."
        case .analyzeCode:
            return "Hubo problemas analizando parte del código. Revisa los logs para más información."
        case .generateModule:
            return "No pude generar el módulo completamente. Los logs te dirán qué fue lo que falló."
        case .updateDependencies:
            return "Algunas dependencias no se pudieron actualizar. Revisa los logs para ver cuáles tuvieron conflictos."
        case .gitCommit:
            return "El commit no se pudo realizar. Los logs te mostrarán si hay conflictos o archivos problemáticos."
        default:
            return "Hubo un problema ejecutando la operación. Los logs tienen los detalles técnicos."
        }
    }

    private func extractTestSummary(from output: String) -> String {
        if output.contains("passed") && output.contains("failed") {
            return "🧪 Tests ejecutados - Ver logs para resultados detallados"
        } else if output.contains("passed") {
            return "🧪 Todos los tests pasaron correctamente"
        } else {
            return "🧪 Tests completados - Ver logs para detalles"
        }
    }
}

//MARK: - Private functions
@MainActor
private extension ChatViewModel {
    
    func manageNewMessage() {
        messages.append(Message(messageToSend, type: .user))
        messages.append(Message("escribiendo...", type: .loading))
        Task {
            do {
                if isProjectAgent {
                    try await sendAgentMessage()
                } else {
                    if let chatID {
                        try await sendMessage(chatID: chatID)
                    } else {
                        try await createChat()
                    }
                }
            } catch {
                handle(this: error)
            }
        }
    }
    
    func createChat() async throws {
        let chatID = try await useCase.createChat(of: customerID)
        try await sendMessage(chatID: chatID)
        self.chatID = chatID
    }
    
    func sendMessage(chatID: Int) async throws {
        let request = MessageRequest(chatID: chatID, message: messageToSend)
        let message = try await useCase.sendMessage(request: request)
        messages.removeLast()
        messages.append(message)
    }

    func sendAgentMessage() async throws {
        do {
            let agentResponse = try await useCase.sendAgentMessage(messageToSend, in: project)
            messages.removeLast()

            let agentMessage = Message(agentResponse.content, type: .bot)
            messages.append(agentMessage)

            if !agentResponse.suggestions.isEmpty {
                let suggestionsText = agentResponse.suggestions.joined(separator: "\n• ")
                let suggestionMessage = Message("💡 Sugerencias:\n• \(suggestionsText)", type: .bot)
                messages.append(suggestionMessage)
            }

            // Refresh suggested actions
            suggestedActionButtons = generateSuggestedActionsForContext()

        } catch {
            // Handle error - remove loading and show error
            messages.removeLast()
            let errorMessage = Message("❌ Error: No pude procesar tu mensaje. \(error.localizedDescription)", type: .error)
            messages.append(errorMessage)

            // Keep showing suggested actions even on error
            if suggestedActionButtons.isEmpty {
                suggestedActionButtons = generateSuggestedActionsForContext()
            }
        }
    }

    private func generateSuggestedActionsForContext() -> [ProjectAction] {
        guard let project = project else { return [] }

        // Generate contextual actions based on project type and recent messages
        var actions: [ProjectAction] = []

        // Always include basic actions
        actions.append(ProjectAction(type: .analyzeCode, description: "Analizar código del proyecto \(project.name)"))

        // Project-type specific actions
        switch project.type {
        case .ios:
            actions.append(ProjectAction(type: .runBuild, description: "Compilar proyecto iOS"))
            actions.append(ProjectAction(type: .runTests, description: "Ejecutar tests de iOS"))
            actions.append(ProjectAction(type: .generateModule, description: "Generar módulo SwiftUI"))
            actions.append(ProjectAction(type: .openInXcode, description: "Abrir en Xcode"))
        case .android:
            actions.append(ProjectAction(type: .runBuild, description: "Compilar proyecto Android"))
            actions.append(ProjectAction(type: .runTests, description: "Ejecutar tests de Android"))
            actions.append(ProjectAction(type: .generateModule, description: "Generar Activity/Fragment"))
            actions.append(ProjectAction(type: .updateDependencies, description: "Actualizar Gradle dependencies"))
        case .flutter:
            actions.append(ProjectAction(type: .runBuild, description: "Compilar app Flutter"))
            actions.append(ProjectAction(type: .runTests, description: "Ejecutar tests Flutter"))
            actions.append(ProjectAction(type: .generateModule, description: "Generar screen Flutter"))
            actions.append(ProjectAction(type: .updateDependencies, description: "Flutter pub upgrade"))
        case .python:
            actions.append(ProjectAction(type: .runTests, description: "Ejecutar tests Python"))
            actions.append(ProjectAction(type: .generateModule, description: "Generar módulo Python"))
            actions.append(ProjectAction(type: .updateDependencies, description: "Actualizar pip requirements"))
        }

        // Common actions
        actions.append(ProjectAction(type: .gitCommit, description: "Commit cambios pendientes"))
        actions.append(ProjectAction(type: .createReadme, description: "Generar README.md"))

        return Array(actions.prefix(6)) // Limit to 6 actions max
    }
    
    func handle(this error: Error) {
        messages.removeLast(2)
        messages.append(Message(messageToSend, type: .warning))
        if let error = error as? AppError,
           error == .noInternet {
            messages.append(Message("chat_PhoneWithoutConnection", type: .error))
        } else {
            messages.append(Message("chat_errorSendingMessage", type: .error))
        }
    }
}

extension ChatViewModel {
    func dismiss() {
        router.dismiss()
    }

    func showLogsWindow() {
        showingLogsWindow = true
    }

    func hideLogsWindow() {
        showingLogsWindow = false
    }
}
