import Foundation

class SystemRepositoryImpl: SystemRepositoryProtocol {
    func checkCommandExists(_ command: String) async throws -> Bool {
        #if os(macOS)
        do {
            print("🔧 Executing command: \(command)")
            let result = try await executeCommand(command)
            let output = result.trimmingCharacters(in: .whitespacesAndNewlines)
            print("📤 Command '\(command)' output: '\(output)'")
            
            // For test commands, success (exit code 0) means the file exists
            // The output will be empty but that's expected for test commands
            let exists = true // If we reach here, the command succeeded (exit code 0)
            print("🔍 Command exists result: \(exists)")
            return exists
        } catch {
            print("❌ Command '\(command)' failed with error: \(error)")
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
            process.launchPath = "/bin/bash"
            process.arguments = ["-c", command]
            
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
            process.environment = environment
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            print("🚀 Executing: \(command) with PATH: \(fullPath)")
            
            process.terminationHandler = { process in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                
                print("📋 Process finished with status: \(process.terminationStatus)")
                print("📋 Output: '\(output)'")
                
                if process.terminationStatus == 0 {
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
            
            do {
                try process.run()
            } catch {
                print("❌ Failed to start process: \(error)")
                continuation.resume(throwing: error)
            }
        }
        #else
        // En iOS, simulamos la ejecución de comandos
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo
        return "Simulated command execution on iOS"
        #endif
    }
}