//
//  ProjectAnalyticsDatasource.swift
//
//
//  Created by Claude on 25/9/24.
//

import Foundation

final class ProjectAnalyticsDatasource: ProjectAnalyticsDatasourceProtocol {
    private let fileManager = FileManager.default
    private let processRunner = ProcessRunner()

    func analyzeProject(_ project: Project) async throws -> AnalysisDetails {
        let fileCount = try countFiles(in: project)
        let codeLines = try await countCodeLines(in: project)
        let dependencies = try await analyzeDependencies(in: project)
        let issues = try await findIssues(in: project)
        let buildInfo = try await analyzeBuildInfo(in: project)
        let gitInfo = try await analyzeGitInfo(in: project)

        return AnalysisDetails(
            fileCount: fileCount,
            codeLines: codeLines,
            dependencies: dependencies,
            issues: issues,
            buildInfo: buildInfo,
            gitInfo: gitInfo
        )
    }

    // MARK: - Private Analysis Methods

    private func countFiles(in project: Project) throws -> Int {
        let enumerator = fileManager.enumerator(atPath: project.path)
        var count = 0

        let relevantExtensions = getRelevantExtensions(for: project.type)

        while let file = enumerator?.nextObject() as? String {
            if relevantExtensions.contains(where: { file.hasSuffix($0) }) &&
               !shouldIgnoreFile(file) {
                count += 1
            }
        }

        return count
    }

    private func countCodeLines(in project: Project) async throws -> Int {
        let relevantExtensions = getRelevantExtensions(for: project.type)
        let findCommand = relevantExtensions.map { "find '\(project.path)' -name '*\($0)'" }.joined(separator: " -o ")

        let result = try await processRunner.run("\(findCommand) | xargs wc -l | tail -1 | awk '{print $1}'", in: project.path)

        if result.exitCode == 0, let lines = Int(result.output.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return lines
        }

        return 0
    }

    private func analyzeDependencies(in project: Project) async throws -> [AnalysisDetails.Dependency] {
        switch project.type {
        case .ios:
            return try await analyzeIOSDependencies(in: project)
        case .android:
            return try await analyzeAndroidDependencies(in: project)
        case .flutter:
            return try await analyzeFlutterDependencies(in: project)
        case .python:
            return try await analyzePythonDependencies(in: project)
        }
    }

    private func findIssues(in project: Project) async throws -> [AnalysisDetails.Issue] {
        var issues: [AnalysisDetails.Issue] = []

        // Check for missing required files
        let requiredFiles = getRequiredFiles(for: project.type)
        for file in requiredFiles {
            let filePath = "\(project.path)/\(file)"
            if !fileManager.fileExists(atPath: filePath) {
                issues.append(
                    AnalysisDetails.Issue(
                        severity: .error,
                        message: "Archivo requerido faltante: \(file)",
                        file: nil,
                        line: nil
                    )
                )
            }
        }

        // Check for build issues (basic check)
        let buildCommand = getBuildCommand(for: project.type)
        let result = try await processRunner.run("\(buildCommand) --dry-run 2>&1 || true", in: project.path)

        if result.exitCode != 0 && !result.error.isEmpty {
            let errorLines = result.error.components(separatedBy: .newlines).prefix(3)
            for error in errorLines {
                if !error.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    issues.append(
                        AnalysisDetails.Issue(
                            severity: .warning,
                            message: error.trimmingCharacters(in: .whitespacesAndNewlines),
                            file: nil,
                            line: nil
                        )
                    )
                }
            }
        }

        // Check for common code issues (simplified)
        let codeIssues = try await findCommonCodeIssues(in: project)
        issues.append(contentsOf: codeIssues)

        return issues
    }

    private func analyzeBuildInfo(in project: Project) async throws -> AnalysisDetails.BuildInfo? {
        let buildCommand = getBuildCommand(for: project.type)
        let result = try await processRunner.run("\(buildCommand) --version 2>&1 || true", in: project.path)

        var buildErrors: [String] = []
        var buildWarnings: [String] = []

        // Try a basic build check
        let buildCheckResult = try await processRunner.run("\(buildCommand) --dry-run 2>&1 || true", in: project.path)

        if buildCheckResult.exitCode != 0 {
            let errorLines = buildCheckResult.error.components(separatedBy: .newlines)
            for line in errorLines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    if trimmed.lowercased().contains("error") {
                        buildErrors.append(trimmed)
                    } else if trimmed.lowercased().contains("warning") {
                        buildWarnings.append(trimmed)
                    }
                }
            }
        }

        return AnalysisDetails.BuildInfo(
            canBuild: buildErrors.isEmpty,
            lastBuildTime: getLastBuildTime(in: project),
            buildErrors: buildErrors,
            buildWarnings: buildWarnings
        )
    }

    private func analyzeGitInfo(in project: Project) async throws -> AnalysisDetails.GitInfo? {
        let gitPath = "\(project.path)/.git"
        guard fileManager.fileExists(atPath: gitPath) else {
            return AnalysisDetails.GitInfo(
                isRepo: false,
                branch: nil,
                uncommittedChanges: 0,
                lastCommit: nil,
                remoteUrl: nil
            )
        }

        let branchResult = try await processRunner.run("git branch --show-current", in: project.path)
        let branch = branchResult.exitCode == 0 ? branchResult.output.trimmingCharacters(in: .whitespacesAndNewlines) : nil

        let statusResult = try await processRunner.run("git status --porcelain", in: project.path)
        let uncommittedChanges = statusResult.exitCode == 0 ? statusResult.output.components(separatedBy: .newlines).filter { !$0.isEmpty }.count : 0

        let lastCommitResult = try await processRunner.run("git log -1 --format=%ct", in: project.path)
        var lastCommit: Date? = nil
        if lastCommitResult.exitCode == 0, let timestamp = TimeInterval(lastCommitResult.output.trimmingCharacters(in: .whitespacesAndNewlines)) {
            lastCommit = Date(timeIntervalSince1970: timestamp)
        }

        let remoteResult = try await processRunner.run("git remote get-url origin", in: project.path)
        let remoteUrl = remoteResult.exitCode == 0 ? remoteResult.output.trimmingCharacters(in: .whitespacesAndNewlines) : nil

        return AnalysisDetails.GitInfo(
            isRepo: true,
            branch: branch,
            uncommittedChanges: uncommittedChanges,
            lastCommit: lastCommit,
            remoteUrl: remoteUrl
        )
    }

    // MARK: - Platform-specific Dependency Analysis

    private func analyzeIOSDependencies(in project: Project) async throws -> [AnalysisDetails.Dependency] {
        var dependencies: [AnalysisDetails.Dependency] = []

        // Check Package.swift for SPM dependencies
        let packageSwiftPath = "\(project.path)/Package.swift"
        if fileManager.fileExists(atPath: packageSwiftPath) {
            let packageContent = try String(contentsOfFile: packageSwiftPath)
            dependencies.append(contentsOf: parseSwiftPackageManager(content: packageContent))
        }

        // Check Podfile for CocoaPods dependencies
        let podfilePath = "\(project.path)/Podfile"
        if fileManager.fileExists(atPath: podfilePath) {
            let podfileContent = try String(contentsOfFile: podfilePath)
            dependencies.append(contentsOf: parsePodfile(content: podfileContent))
        }

        return dependencies
    }

    private func analyzeAndroidDependencies(in project: Project) async throws -> [AnalysisDetails.Dependency] {
        var dependencies: [AnalysisDetails.Dependency] = []

        // Check build.gradle files
        let buildGradlePaths = [
            "\(project.path)/build.gradle",
            "\(project.path)/app/build.gradle",
            "\(project.path)/build.gradle.kts",
            "\(project.path)/app/build.gradle.kts"
        ]

        for path in buildGradlePaths {
            if fileManager.fileExists(atPath: path) {
                let gradleContent = try String(contentsOfFile: path)
                dependencies.append(contentsOf: parseGradleDependencies(content: gradleContent))
            }
        }

        return dependencies
    }

    private func analyzeFlutterDependencies(in project: Project) async throws -> [AnalysisDetails.Dependency] {
        let pubspecPath = "\(project.path)/pubspec.yaml"
        guard fileManager.fileExists(atPath: pubspecPath) else { return [] }

        let pubspecContent = try String(contentsOfFile: pubspecPath)
        return parsePubspecDependencies(content: pubspecContent)
    }

    private func analyzePythonDependencies(in project: Project) async throws -> [AnalysisDetails.Dependency] {
        var dependencies: [AnalysisDetails.Dependency] = []

        // Check requirements.txt
        let requirementsPath = "\(project.path)/requirements.txt"
        if fileManager.fileExists(atPath: requirementsPath) {
            let requirementsContent = try String(contentsOfFile: requirementsPath)
            dependencies.append(contentsOf: parseRequirementsTxt(content: requirementsContent))
        }

        // Check pyproject.toml
        let pyprojectPath = "\(project.path)/pyproject.toml"
        if fileManager.fileExists(atPath: pyprojectPath) {
            let pyprojectContent = try String(contentsOfFile: pyprojectPath)
            dependencies.append(contentsOf: parsePyprojectToml(content: pyprojectContent))
        }

        return dependencies
    }

    // MARK: - Dependency Parsers

    private func parseSwiftPackageManager(content: String) -> [AnalysisDetails.Dependency] {
        var dependencies: [AnalysisDetails.Dependency] = []

        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            if line.contains(".package(") {
                // Simple parsing - would need more sophisticated parsing in production
                let parts = line.components(separatedBy: "\"")
                if parts.count >= 2 {
                    let url = parts[1]
                    let name = URL(string: url)?.lastPathComponent.replacingOccurrences(of: ".git", with: "") ?? "Unknown"
                    dependencies.append(
                        AnalysisDetails.Dependency(
                            name: name,
                            version: nil,
                            isUpdatable: true,
                            source: .spm
                        )
                    )
                }
            }
        }

        return dependencies
    }

    private func parsePodfile(content: String) -> [AnalysisDetails.Dependency] {
        var dependencies: [AnalysisDetails.Dependency] = []

        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("pod ") {
                let parts = line.components(separatedBy: "'")
                if parts.count >= 2 {
                    dependencies.append(
                        AnalysisDetails.Dependency(
                            name: parts[1],
                            version: parts.count >= 4 ? parts[3] : nil,
                            isUpdatable: true,
                            source: .cocoapods
                        )
                    )
                }
            }
        }

        return dependencies
    }

    private func parseGradleDependencies(content: String) -> [AnalysisDetails.Dependency] {
        var dependencies: [AnalysisDetails.Dependency] = []

        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("implementation ") || trimmed.contains("compile ") {
                let parts = trimmed.components(separatedBy: "'")
                if parts.count >= 2 {
                    let dependencyString = parts[1]
                    let components = dependencyString.components(separatedBy: ":")
                    if components.count >= 2 {
                        dependencies.append(
                            AnalysisDetails.Dependency(
                                name: components[1],
                                version: components.count >= 3 ? components[2] : nil,
                                isUpdatable: true,
                                source: .gradle
                            )
                        )
                    }
                }
            }
        }

        return dependencies
    }

    private func parsePubspecDependencies(content: String) -> [AnalysisDetails.Dependency] {
        var dependencies: [AnalysisDetails.Dependency] = []

        let lines = content.components(separatedBy: .newlines)
        var inDependenciesSection = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed == "dependencies:" {
                inDependenciesSection = true
                continue
            }

            if inDependenciesSection {
                if !line.hasPrefix(" ") && !trimmed.isEmpty {
                    inDependenciesSection = false
                    continue
                }

                if line.hasPrefix("  ") && line.contains(":") {
                    let parts = line.components(separatedBy: ":")
                    if parts.count >= 2 {
                        let name = parts[0].trimmingCharacters(in: .whitespaces)
                        let version = parts[1].trimmingCharacters(in: .whitespaces)

                        dependencies.append(
                            AnalysisDetails.Dependency(
                                name: name,
                                version: version.isEmpty ? nil : version,
                                isUpdatable: true,
                                source: .npm
                            )
                        )
                    }
                }
            }
        }

        return dependencies
    }

    private func parseRequirementsTxt(content: String) -> [AnalysisDetails.Dependency] {
        var dependencies: [AnalysisDetails.Dependency] = []

        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty && !trimmed.hasPrefix("#") {
                let parts = trimmed.components(separatedBy: "==")
                let name = parts[0].trimmingCharacters(in: .whitespaces)
                let version = parts.count >= 2 ? parts[1].trimmingCharacters(in: .whitespaces) : nil

                dependencies.append(
                    AnalysisDetails.Dependency(
                        name: name,
                        version: version,
                        isUpdatable: true,
                        source: .pip
                    )
                )
            }
        }

        return dependencies
    }

    private func parsePyprojectToml(content: String) -> [AnalysisDetails.Dependency] {
        // Simplified TOML parsing - would need proper TOML parser in production
        var dependencies: [AnalysisDetails.Dependency] = []

        let lines = content.components(separatedBy: .newlines)
        var inDependenciesSection = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.contains("[tool.poetry.dependencies]") || trimmed.contains("dependencies = [") {
                inDependenciesSection = true
                continue
            }

            if inDependenciesSection {
                if trimmed.hasPrefix("[") && !trimmed.contains("dependencies") {
                    inDependenciesSection = false
                    continue
                }

                if trimmed.contains("=") {
                    let parts = trimmed.components(separatedBy: "=")
                    if parts.count >= 2 {
                        let name = parts[0].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "")
                        let version = parts[1].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "")

                        dependencies.append(
                            AnalysisDetails.Dependency(
                                name: name,
                                version: version,
                                isUpdatable: true,
                                source: .pip
                            )
                        )
                    }
                }
            }
        }

        return dependencies
    }

    // MARK: - Helper Methods

    private func findCommonCodeIssues(in project: Project) async throws -> [AnalysisDetails.Issue] {
        var issues: [AnalysisDetails.Issue] = []

        // Check for TODOs and FIXMEs
        let grepResult = try await processRunner.run("grep -rn 'TODO\\|FIXME' '\(project.path)' --include='*.\(getMainExtension(for: project.type))' || true", in: project.path)

        if grepResult.exitCode == 0 && !grepResult.output.isEmpty {
            let todoLines = grepResult.output.components(separatedBy: .newlines).prefix(5)
            for line in todoLines {
                if !line.isEmpty {
                    let parts = line.components(separatedBy: ":")
                    if parts.count >= 3 {
                        let file = parts[0]
                        let lineNumber = Int(parts[1])
                        let message = parts[2].trimmingCharacters(in: .whitespaces)

                        issues.append(
                            AnalysisDetails.Issue(
                                severity: .info,
                                message: message,
                                file: file,
                                line: lineNumber
                            )
                        )
                    }
                }
            }
        }

        return issues
    }

    private func getLastBuildTime(in project: Project) -> Date? {
        let buildPaths = getBuildPaths(for: project.type, in: project.path)

        var latestDate: Date?
        for path in buildPaths {
            if fileManager.fileExists(atPath: path) {
                do {
                    let attributes = try fileManager.attributesOfItem(atPath: path)
                    if let modificationDate = attributes[.modificationDate] as? Date {
                        if latestDate == nil || modificationDate > latestDate! {
                            latestDate = modificationDate
                        }
                    }
                } catch {
                    continue
                }
            }
        }

        return latestDate
    }

    private func getRelevantExtensions(for type: ProjectType) -> [String] {
        switch type {
        case .ios: return [".swift", ".m", ".h"]
        case .android: return [".kt", ".java"]
        case .flutter: return [".dart"]
        case .python: return [".py"]
        }
    }

    private func getMainExtension(for type: ProjectType) -> String {
        switch type {
        case .ios: return "swift"
        case .android: return "kt"
        case .flutter: return "dart"
        case .python: return "py"
        }
    }

    private func getRequiredFiles(for type: ProjectType) -> [String] {
        switch type {
        case .ios: return ["Info.plist"]
        case .android: return ["build.gradle", "AndroidManifest.xml"]
        case .flutter: return ["pubspec.yaml"]
        case .python: return []
        }
    }

    private func getBuildCommand(for type: ProjectType) -> String {
        switch type {
        case .ios: return "xcodebuild"
        case .android: return "./gradlew"
        case .flutter: return "flutter"
        case .python: return "python"
        }
    }

    private func getBuildPaths(for type: ProjectType, in projectPath: String) -> [String] {
        switch type {
        case .ios: return ["\(projectPath)/build", "\(projectPath)/DerivedData"]
        case .android: return ["\(projectPath)/build", "\(projectPath)/app/build"]
        case .flutter: return ["\(projectPath)/build"]
        case .python: return ["\(projectPath)/__pycache__"]
        }
    }

    private func shouldIgnoreFile(_ file: String) -> Bool {
        let ignoredPaths = [
            "/.git/",
            "/node_modules/",
            "/build/",
            "/dist/",
            "/__pycache__/",
            "/.idea/",
            "/.vscode/",
            "/Pods/"
        ]

        return ignoredPaths.contains { file.contains($0) }
    }
}

// MARK: - Process Runner Helper
private class ProcessRunner {
    struct ProcessResult {
        let output: String
        let error: String
        let exitCode: Int32
    }

    func run(_ command: String, in directory: String) async throws -> ProcessResult {
        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = ["-c", "cd '\(directory)' && \(command)"]

            let outputPipe = Pipe()
            let errorPipe = Pipe()

            process.standardOutput = outputPipe
            process.standardError = errorPipe

            do {
                try process.run()
                process.waitUntilExit()

                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                let output = String(data: outputData, encoding: .utf8) ?? ""
                let error = String(data: errorData, encoding: .utf8) ?? ""

                let result = ProcessResult(
                    output: output,
                    error: error,
                    exitCode: process.terminationStatus
                )

                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}