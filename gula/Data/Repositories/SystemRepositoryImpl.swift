import Foundation
#if os(macOS)
import AppKit
#endif

class SystemRepositoryImpl: SystemRepositoryProtocol {
    func checkCommandExists(_ command: String) async throws -> Bool {
        #if os(macOS)
        do {
            #if DEBUG
            print("🔧 Executing command: \(command)")
            #endif
            let result = try await executeCommand(command)
            let output = result.trimmingCharacters(in: .whitespacesAndNewlines)
            #if DEBUG
            print("📤 Command '\(command)' output: '\(output)'")
            #endif

            // For test commands, success (exit code 0) means the file exists
            // The output will be empty but that's expected for test commands
            let exists = true // If we reach here, the command succeeded (exit code 0)
            #if DEBUG
            print("🔍 Command exists result: \(exists)")
            #endif
            return exists
        } catch {
            #if DEBUG
            print("❌ Command '\(command)' failed with error: \(error)")
            #endif
            // For test commands, failure means the file doesn't exist
            return false
        }
        #else
        // En iOS/simulador, simulamos el comportamiento para testing
        #if DEBUG
        // En debug en iOS, simulamos que las dependencias están instaladas
        print("DEBUG iOS: Simulating command check for: \(command)")
        return true
        #else
        return command.contains("brew") || command.contains("gula")
        #endif
        #endif
    }

    func executeCommand(_ command: String) async throws -> String {
        #if os(macOS)
        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()

            // Set up the environment with proper PATH
            var environment = ProcessInfo.processInfo.environment
            let commonPaths = [
                "/usr/local/bin",
                "/opt/homebrew/bin",
                "/usr/bin",
                "/bin",
                "/usr/sbin",
                "/sbin"
            ]
            let currentPath = environment["PATH"] ?? ""
            let fullPath = (commonPaths + [currentPath]).joined(separator: ":")
            environment["PATH"] = fullPath

            // Extract working directory from command if it starts with cd
            var workingDirectory: String? = nil
            var actualCommand = command

            // Check if command starts with cd and extract the directory
            if command.hasPrefix("cd \"") {
                // Find the first occurrence of '" && ' to split correctly
                if let range = command.range(of: "\" && ") {
                    let cdPart = String(command[..<range.lowerBound])
                    workingDirectory = String(cdPart.dropFirst(4)) // Remove 'cd "' prefix (4 characters)
                    actualCommand = String(command[range.upperBound...])
                    #if DEBUG
                    print("🔍 Extracted working directory: '\(workingDirectory ?? "none")'")
                    print("🔍 Extracted command: '\(actualCommand)'")
                    #endif
                }
            }

            // Set the working directory if extracted
            if let workingDir = workingDirectory {
                let url = URL(fileURLWithPath: workingDir)
                process.currentDirectoryURL = url
                #if DEBUG
                print("📁 Set process working directory to: \(workingDir)")
                #endif
            }

            // Check if we can execute directly without bash wrapper
            // Note: PATH="$PATH" is handled separately, so we ignore $ in that context
            let commandWithoutPathPrefix = actualCommand.replacingOccurrences(of: #"PATH="[^"]*"\s*"#, with: "", options: .regularExpression)
            let needsBash = actualCommand.contains("|") || actualCommand.contains(">") ||
                           actualCommand.contains("<") || actualCommand.contains("&&") ||
                           actualCommand.contains("||") || actualCommand.contains(";") ||
                           actualCommand.contains("echo") || commandWithoutPathPrefix.contains("$")

            if !needsBash && (actualCommand.hasPrefix("gula ") || actualCommand.hasPrefix("/opt/homebrew/bin/gula ") || actualCommand.hasPrefix("PATH=") || actualCommand.contains("/gula ")) {
                // Execute gula directly for maximum performance
                // Parse command properly handling PATH= prefix
                var commandParts: [String] = []
                var gulaPath: String? = nil

                // Simple regex-free parsing
                let trimmed = actualCommand.trimmingCharacters(in: .whitespaces)

                // Remove PATH="..." prefix if present
                var commandToProcess = trimmed
                if trimmed.hasPrefix("PATH=") {
                    // Find the end of PATH assignment (space after closing quote or first space)
                    if let endIndex = trimmed.firstIndex(of: " ") {
                        commandToProcess = String(trimmed[trimmed.index(after: endIndex)...]).trimmingCharacters(in: .whitespaces)
                    }
                }

                // Now parse the actual command
                let parts = commandToProcess.split(separator: " ", omittingEmptySubsequences: true).map(String.init)

                if let firstPart = parts.first {
                    if firstPart.hasSuffix("/gula") || firstPart == "gula" {
                        // Found gula executable
                        if firstPart == "gula" {
                            gulaPath = "/opt/homebrew/bin/gula"
                        } else {
                            gulaPath = firstPart
                        }
                        commandParts = Array(parts.dropFirst())
                    }
                }

                if let gula = gulaPath, !gula.isEmpty, FileManager.default.fileExists(atPath: gula) {
                    #if DEBUG
                    print("🚀 Direct execution: \(gula) \(commandParts.joined(separator: " "))")
                    #endif
                    process.executableURL = URL(fileURLWithPath: gula)
                    process.arguments = commandParts
                    process.environment = environment
                } else {
                    // Fallback to bash
                    #if DEBUG
                    print("🐚 Fallback to bash - could not parse: \(actualCommand)")
                    #endif
                    process.executableURL = URL(fileURLWithPath: "/bin/bash")
                    let enhancedCommand = """
                    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH";
                    \(actualCommand)
                    """
                    process.arguments = ["-c", enhancedCommand]
                    process.environment = environment
                }
            } else {
                // Use bash for complex commands
                #if DEBUG
                print("🐚 Using bash wrapper for: \(actualCommand)")
                #endif
                process.executableURL = URL(fileURLWithPath: "/bin/bash")
                let enhancedCommand = """
                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH";
                \(actualCommand)
                """
                process.arguments = ["-c", enhancedCommand]
                process.environment = environment
            }

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            // StandardInput will be handled by the shell command (echo piped to gula)
            // No need to set it to null since we're providing automated inputs via echo

            #if DEBUG
            print("🚀 Executing: \(command) with PATH: \(fullPath)")
            #endif

            // Add a timer to force termination after 5 minutes
            let timer = Timer.scheduledTimer(withTimeInterval: 300.0, repeats: false) { _ in
                #if DEBUG
                print("⏰ Command timed out, terminating process")
                #endif
                process.terminate()

                let error = NSError(
                    domain: "SystemRepository",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Command timed out after 5 minutes"]
                )
                continuation.resume(throwing: error)
            }

            process.terminationHandler = { process in
                timer.invalidate() // Cancel the timeout timer

                // Use async reading to avoid blocking
                let fileHandle = pipe.fileHandleForReading
                var data = Data()

                // Read available data without blocking
                do {
                    if #available(macOS 10.15.4, *) {
                        // Use non-blocking read if available
                        data = try fileHandle.readToEnd() ?? Data()
                    } else {
                        data = fileHandle.readDataToEndOfFile()
                    }
                } catch {
                    #if DEBUG
                    print("⚠️ Error reading pipe data: \(error)")
                    #endif
                    data = Data()
                }

                let output = String(data: data, encoding: .utf8) ?? ""

                #if DEBUG
                print("📋 Process finished with status: \(process.terminationStatus)")
                print("📋 Output: '\(output)'")
                #endif

                if process.terminationStatus == 0 {
                    continuation.resume(returning: output)
                } else if process.terminationStatus == 15 { // SIGTERM (timeout)
                    let error = NSError(
                        domain: "SystemRepository",
                        code: Int(process.terminationStatus),
                        userInfo: [NSLocalizedDescriptionKey: "Command was terminated due to timeout"]
                    )
                    continuation.resume(throwing: error)
                } else {
                    // For gula commands, check if the output indicates partial success
                    // Even with exit code 1, if we see expected gula output, treat as success
                    let lowercaseOutput = output.lowercased()
                    if command.contains("gula") && (
                        lowercaseOutput.contains("empezando la instalación") ||
                        lowercaseOutput.contains("starting installation") ||
                        lowercaseOutput.contains("✅ el prefijo de homebrew") ||
                        lowercaseOutput.contains("arquetipo") ||
                        lowercaseOutput.contains("archetype")
                    ) {
                        #if DEBUG
                        print("⚠️ Gula command had exit code \(process.terminationStatus) but produced expected output, treating as success")
                        #endif
                        continuation.resume(returning: output)
                    } else {
                        let error = NSError(
                            domain: "SystemRepository",
                            code: Int(process.terminationStatus),
                            userInfo: [NSLocalizedDescriptionKey: "Command failed: \(output)"]
                        )
                        continuation.resume(throwing: error)
                    }
                }
            }

            do {
                try process.run()
            } catch {
                timer.invalidate()
                #if DEBUG
                print("❌ Failed to start process: \(error)")
                #endif
                continuation.resume(throwing: error)
            }
        }
        #else
        // En iOS, simulamos la ejecución de comandos
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo
        return "Simulated command execution on iOS"
        #endif
    }
    
    @MainActor
    func executeCommandInTerminal(_ command: String) async throws -> String {
        #if os(macOS)
        return try await withCheckedThrowingContinuation { continuation in
            let escapedCommand = command.replacingOccurrences(of: "\"", with: "\\\"")
            
            let appleScript = """
            tell application "Terminal"
                activate
                set currentTab to do script "\(escapedCommand)"
                
                -- Wait for the command to complete
                repeat
                    delay 3
                    if not busy of currentTab then exit repeat
                end repeat
                
                -- Get the output
                set commandOutput to contents of currentTab
                
                -- Close the tab gracefully
                delay 1
                try
                    set windowOfTab to (get window of currentTab)
                    if (count of tabs of windowOfTab) > 1 then
                        -- Multiple tabs, just close this tab
                        close currentTab
                    else
                        -- Only tab, close the window
                        close windowOfTab
                    end if
                on error errorMessage
                    -- If closing fails, try alternative approaches
                    try
                        -- Try to quit current tab's process first
                        do script "exit" in currentTab
                        delay 0.5
                        close currentTab
                    on error
                        -- Last resort: force close if it's the only window
                        try
                            if (count of windows of application "Terminal") = 1 and (count of tabs of (get window of currentTab)) = 1 then
                                quit application "Terminal"
                            end if
                        end try
                    end try
                end try
                
                return commandOutput
            end tell
            """
            
            let task = Process()
            task.launchPath = "/usr/bin/osascript"
            task.arguments = ["-e", appleScript]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            
            task.terminationHandler = { process in
                // Use async reading to avoid blocking
                let fileHandle = pipe.fileHandleForReading
                var data = Data()

                // Read available data without blocking
                do {
                    if #available(macOS 10.15.4, *) {
                        data = try fileHandle.readToEnd() ?? Data()
                    } else {
                        data = fileHandle.readDataToEndOfFile()
                    }
                } catch {
                    #if DEBUG
                    print("⚠️ Error reading pipe data: \(error)")
                    #endif
                    data = Data()
                }

                let output = String(data: data, encoding: .utf8) ?? ""

                #if DEBUG
                print("📋 AppleScript finished with status: \(process.terminationStatus)")
                print("📋 Terminal output: '\(output)'")
                #endif

                if process.terminationStatus == 0 {
                    continuation.resume(returning: output)
                } else {
                    let error = NSError(
                        domain: "SystemRepository",
                        code: Int(process.terminationStatus),
                        userInfo: [NSLocalizedDescriptionKey: "Terminal execution failed: \(output)"]
                    )
                    continuation.resume(throwing: error)
                }
            }

            do {
                try task.run()
            } catch {
                #if DEBUG
                print("❌ Failed to execute AppleScript: \(error)")
                #endif
                continuation.resume(throwing: error)
            }
        }
        #else
        throw NSError(domain: "SystemRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Terminal execution not supported on this platform"])
        #endif
    }

    func checkInternetConnectivity() async throws -> Bool {
        #if os(macOS)
        do {
            #if DEBUG
            print("🌐 Checking internet connectivity...")
            #endif

            // Try to ping a reliable public DNS server (Google's 8.8.8.8)
            let result = try await executeCommand("ping -c 1 -W 3000 8.8.8.8")
            let hasConnectivity = result.contains("1 packets transmitted, 1 received") || result.contains("1 packets transmitted, 1 packets received")

            #if DEBUG
            print("🌐 Internet connectivity: \(hasConnectivity ? "✅ Available" : "❌ Not available")")
            #endif
            return hasConnectivity
        } catch {
            #if DEBUG
            print("❌ Error checking internet connectivity: \(error)")
            #endif
            return false
        }
        #else
        // En iOS/simulador, simulamos que hay conectividad
        #if DEBUG
        print("DEBUG iOS: Simulating internet connectivity check")
        #endif
        return true
        #endif
    }
}