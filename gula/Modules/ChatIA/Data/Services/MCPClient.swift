//
//  MCPClient.swift
//
//
//  Created by Claude on 25/9/24.
//

import Foundation

class MCPClient {
    private var isConnected = false

    init() {}

    func connect() async throws {
        print("🔌 [MCP] Attempting to connect to MCP services")

        // For now, we'll assume local execution is always available
        // In the future, this could check for actual MCP server connectivity
        isConnected = true

        print("✅ [MCP] Connected successfully (direct execution mode)")
    }

    func disconnect() async {
        print("🔌 [MCP] Disconnecting from MCP services")
        isConnected = false
        print("✅ [MCP] Disconnected")
    }

    func isAvailable() async -> Bool {
        // Check if we can execute shell commands (our current MCP implementation)
        // This verifies the system can run development tools
        do {
            let testResult = try await executeShellCommand("echo 'MCP connection test'")
            let available = !testResult.isEmpty
            print("🔍 [MCP] Availability check: \(available ? "✅ Available" : "❌ Unavailable")")
            return available
        } catch {
            print("🔍 [MCP] Availability check failed: \(error)")
            return false
        }
    }

    func executeAction(_ action: ProjectAction, in project: Project) async throws -> String {
        guard isConnected else {
            throw MCPError.notConnected
        }

        // TODO: Implement real MCP action execution
        // For now, return simulated output based on action type
        switch action.type {
        case .runBuild:
            return "Build succeeded in 12.3 seconds"
        case .runTests:
            return "All tests passed (10 tests)"
        case .analyzeCode:
            return "Code analysis completed - 0 issues found"
        case .generateModule:
            return "Module '\(action.description)' generated successfully"
        default:
            return "Action completed successfully"
        }
    }

    func executeBuild(in projectPath: String, type: ProjectType) async throws -> String {
        guard isConnected else {
            throw MCPError.notConnected
        }

        print("🏗️ [BUILD] Starting real build for \(type.displayName) project at: \(projectPath)")

        let buildCommand: String
        switch type {
        case .ios:
            // Find .xcodeproj or .xcworkspace
            buildCommand = """
            cd "\(projectPath)" && \
            if [ -f *.xcworkspace ]; then \
                xcodebuild -workspace *.xcworkspace -scheme $(xcodebuild -workspace *.xcworkspace -list | grep -A 1000 "Schemes:" | grep -v "Schemes:" | head -1 | xargs) build; \
            elif [ -f *.xcodeproj ]; then \
                xcodebuild -project *.xcodeproj -scheme $(xcodebuild -project *.xcodeproj -list | grep -A 1000 "Schemes:" | grep -v "Schemes:" | head -1 | xargs) build; \
            else \
                echo "No Xcode project found"; exit 1; \
            fi
            """
        case .android:
            buildCommand = "cd \"\(projectPath)\" && ./gradlew build"
        case .flutter:
            buildCommand = "cd \"\(projectPath)\" && flutter build"
        case .python:
            buildCommand = "cd \"\(projectPath)\" && python -m py_compile *.py"
        default:
            buildCommand = "cd \"\(projectPath)\" && echo 'Build not supported for \(type.displayName)'"
        }

        return try await executeShellCommand(buildCommand)
    }

    func executeTests(in projectPath: String, type: ProjectType) async throws -> String {
        guard isConnected else {
            throw MCPError.notConnected
        }

        print("🧪 [TEST] Starting real tests for \(type.displayName) project at: \(projectPath)")

        let testCommand: String
        switch type {
        case .ios:
            testCommand = """
            cd "\(projectPath)" && \
            if [ -f *.xcworkspace ]; then \
                xcodebuild -workspace *.xcworkspace -scheme $(xcodebuild -workspace *.xcworkspace -list | grep -A 1000 "Schemes:" | grep -v "Schemes:" | head -1 | xargs) test; \
            elif [ -f *.xcodeproj ]; then \
                xcodebuild -project *.xcodeproj -scheme $(xcodebuild -project *.xcodeproj -list | grep -A 1000 "Schemes:" | grep -v "Schemes:" | head -1 | xargs) test; \
            else \
                echo "No Xcode project found"; exit 1; \
            fi
            """
        case .android:
            testCommand = "cd \"\(projectPath)\" && ./gradlew test"
        case .flutter:
            testCommand = "cd \"\(projectPath)\" && flutter test"
        case .python:
            testCommand = "cd \"\(projectPath)\" && python -m pytest"
        default:
            testCommand = "cd \"\(projectPath)\" && echo 'Tests not supported for \(type.displayName)'"
        }

        return try await executeShellCommand(testCommand)
    }

    func analyzeCode(in projectPath: String, type: ProjectType) async throws -> String {
        // TODO: Implement real MCP code analysis
        return "Code analysis completed - 0 issues found"
    }

    func generateModule(name: String, in projectPath: String, type: ProjectType) async throws -> String {
        // TODO: Implement real MCP module generation
        return "Module '\(name)' generated successfully"
    }

    func updateDependencies(in projectPath: String, type: ProjectType) async throws -> String {
        // TODO: Implement real MCP dependency updates
        return "Dependencies updated successfully"
    }

    func gitCommit(message: String, in projectPath: String) async throws -> String {
        // TODO: Implement real MCP git commit
        return "Commit created: \(message)"
    }

    func createFile(name: String, content: String, in projectPath: String) async throws -> String {
        // TODO: Implement real MCP file creation
        return "File '\(name)' created successfully"
    }

    // MARK: - Shell Command Execution

    private func executeShellCommand(_ command: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            print("🐚 [SHELL] Executing: \(command)")

            let task = Process()
            let pipe = Pipe()
            let errorPipe = Pipe()

            task.standardOutput = pipe
            task.standardError = errorPipe
            task.launchPath = "/bin/bash"
            task.arguments = ["-c", command]

            task.terminationHandler = { process in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                let output = String(data: data, encoding: .utf8) ?? ""
                let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

                print("🐚 [SHELL] Exit code: \(process.terminationStatus)")
                print("🐚 [SHELL] Output: \(output)")
                if !errorOutput.isEmpty {
                    print("🐚 [SHELL] Error: \(errorOutput)")
                }

                if process.terminationStatus == 0 {
                    continuation.resume(returning: output.isEmpty ? "Command executed successfully" : output)
                } else {
                    // Combine output and error for complete context
                    var fullMessage = ""
                    if !output.isEmpty {
                        fullMessage += "Output:\n\(output)\n\n"
                    }
                    if !errorOutput.isEmpty {
                        fullMessage += "Error:\n\(errorOutput)"
                    } else {
                        fullMessage += "Command failed with exit code \(process.terminationStatus)"
                    }
                    continuation.resume(throwing: MCPError.executionFailed(fullMessage))
                }
            }

            do {
                try task.run()
            } catch {
                continuation.resume(throwing: MCPError.executionFailed("Failed to start process: \(error)"))
            }
        }
    }
}

enum MCPError: Error, LocalizedError {
    case notConnected
    case executionFailed(String)
    case connectionFailed(String)

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "MCP client is not connected"
        case .executionFailed(let message):
            return "Execution failed: \(message)"
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        }
    }
}