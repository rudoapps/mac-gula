import Foundation

class SystemRepositoryImpl: SystemRepositoryProtocol {
    func checkCommandExists(_ command: String) async throws -> Bool {
        #if os(macOS)
        do {
            let result = try await executeCommand(command)
            let output = result.trimmingCharacters(in: .whitespacesAndNewlines)
            print("Command '\(command)' output: '\(output)'")
            return !output.isEmpty && !output.contains("not found") && !output.contains("command not found")
        } catch {
            print("Command '\(command)' failed with error: \(error)")
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
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            process.terminationHandler = { process in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                
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