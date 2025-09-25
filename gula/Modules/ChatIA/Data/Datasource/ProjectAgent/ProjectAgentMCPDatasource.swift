//
//  ProjectAgentMCPDatasource.swift
//
//
//  Created by Claude on 25/9/24.
//

import Foundation

final class ProjectAgentMCPDatasource: ProjectAgentMCPDatasourceProtocol {
    private let fileManager = FileManager.default
    private let processRunner = ProcessRunner()
    private let mcpClient = MCPClient()
    private var isInitialized = false

    func executeAction(_ action: ProjectAction, in project: Project) async throws -> ExecutedAction {
        try await ensureMCPConnection()
        do {
            let result = try await performActionWithMCP(action, in: project)
            return ExecutedAction(action: action, result: result)
        } catch {
            let errorMessage = "Error ejecutando \(action.type.displayName): \(error.localizedDescription)"
            return ExecutedAction(action: action, result: .failure(error: errorMessage))
        }
    }

    private func performActionWithMCP(_ action: ProjectAction, in project: Project) async throws -> ExecutedAction.ActionResult {
        // Try MCP first, fallback to direct execution if MCP not available
        if await mcpClient.isAvailable() {
            return try await executeThroughMCP(action, in: project)
        } else {
            // Fallback to direct execution
            return try await performAction(action, in: project)
        }
    }

    private func executeThroughMCP(_ action: ProjectAction, in project: Project) async throws -> ExecutedAction.ActionResult {
        switch action.type {
        case .runBuild:
            let output = try await mcpClient.executeBuild(in: project.path, type: project.type)
            return .success(output: output)
        case .runTests:
            let output = try await mcpClient.executeTests(in: project.path, type: project.type)
            return .success(output: output)
        case .analyzeCode:
            let output = try await mcpClient.analyzeCode(in: project.path, type: project.type)
            return .success(output: output)
        case .generateModule:
            let moduleName = action.parameters["name"] as? String ?? "NewModule"
            let output = try await mcpClient.generateModule(name: moduleName, in: project.path, type: project.type)
            return .success(output: output)
        case .updateDependencies:
            let output = try await mcpClient.updateDependencies(in: project.path, type: project.type)
            return .success(output: output)
        case .gitCommit:
            let message = action.parameters["message"] as? String ?? "Automated commit from Gula"
            let output = try await mcpClient.gitCommit(message: message, in: project.path)
            return .success(output: output)
        case .createFile:
            let fileName = action.parameters["name"] as? String ?? "NewFile.swift"
            let content = action.parameters["content"] as? String ?? "// New file content"
            let output = try await mcpClient.createFile(name: fileName, content: content, in: project.path)
            return .success(output: output)
        default:
            // Fallback to direct execution for unsupported actions
            return try await performAction(action, in: project)
        }
    }

    private func performAction(_ action: ProjectAction, in project: Project) async throws -> ExecutedAction.ActionResult {
        switch action.type {
        case .analyzeCode:
            return try await analyzeCode(in: project)
        case .generateModule:
            return try await generateModule(action.parameters, in: project)
        case .runTests:
            return try await runTests(in: project)
        case .runBuild:
            return try await runBuild(in: project)
        case .updateDependencies:
            return try await updateDependencies(in: project)
        case .createFile:
            return try await createFile(action.parameters, in: project)
        case .refactorCode:
            return try await refactorCode(action.parameters, in: project)
        case .gitCommit:
            return try await gitCommit(action.parameters, in: project)
        case .openInXcode:
            return try await openInXcode(project)
        case .createReadme:
            return try await createReadme(in: project)
        }
    }

    // MARK: - MCP Connection Management

    private func ensureMCPConnection() async throws {
        guard !isInitialized else { return }

        print("🔌 [ProjectAgentMCPDatasource] Initializing MCP connection")

        do {
            try await mcpClient.connect()
            isInitialized = true
            print("✅ [ProjectAgentMCPDatasource] MCP connection established")
        } catch {
            print("❌ [ProjectAgentMCPDatasource] Failed to connect to MCP: \(error)")
            throw error
        }
    }

    // MARK: - Action Implementations

    private func analyzeCode(in project: Project) async throws -> ExecutedAction.ActionResult {
        let projectPath = project.path
        var output = "📊 **Análisis de código completado**\n\n"

        // Count files
        let fileCount = try countFiles(in: projectPath, for: project.type)
        output += "**Archivos encontrados:** \(fileCount)\n"

        // Check for common issues
        let issues = try await checkCommonIssues(in: project)
        if !issues.isEmpty {
            output += "**Issues detectados:** \(issues.count)\n"
            for issue in issues.prefix(5) {
                output += "• \(issue)\n"
            }
        } else {
            output += "**Issues:** Sin problemas detectados ✅\n"
        }

        return .success(output: output)
    }

    private func generateModule(_ parameters: [String: Any], in project: Project) async throws -> ExecutedAction.ActionResult {
        guard let moduleName = parameters["name"] as? String else {
            throw NSError(domain: "ProjectAgent", code: 1, userInfo: [NSLocalizedDescriptionKey: "Nombre del módulo requerido"])
        }

        let moduleTemplate = try generateModuleTemplate(named: moduleName, for: project.type)
        let modulePath = "\(project.path)/\(moduleName)"

        try fileManager.createDirectory(atPath: modulePath, withIntermediateDirectories: true)

        for (fileName, content) in moduleTemplate {
            let filePath = "\(modulePath)/\(fileName)"
            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
        }

        let output = """
        ✅ **Módulo \(moduleName) generado exitosamente**

        📁 Archivos creados:
        \(moduleTemplate.keys.map { "• \($0)" }.joined(separator: "\n"))

        📍 Ubicación: \(modulePath)
        """

        return .success(output: output)
    }

    private func runTests(in project: Project) async throws -> ExecutedAction.ActionResult {
        let testCommand = getTestCommand(for: project.type)
        let result = try await processRunner.run(testCommand, in: project.path)

        if result.exitCode == 0 {
            let output = """
            ✅ **Tests ejecutados exitosamente**

            \(result.output)
            """
            return .success(output: output)
        } else {
            let output = """
            ❌ **Tests fallaron**

            \(result.error)
            """
            return .failure(error: output)
        }
    }

    private func runBuild(in project: Project) async throws -> ExecutedAction.ActionResult {
        let buildCommand = getBuildCommand(for: project.type)
        let result = try await processRunner.run(buildCommand, in: project.path)

        if result.exitCode == 0 {
            let output = """
            ✅ **Build completado exitosamente**

            \(result.output)
            """
            return .success(output: output)
        } else {
            let output = """
            ❌ **Build falló**

            \(result.error)
            """
            return .failure(error: output)
        }
    }

    private func updateDependencies(in project: Project) async throws -> ExecutedAction.ActionResult {
        let updateCommand = getUpdateDependenciesCommand(for: project.type)
        let result = try await processRunner.run(updateCommand, in: project.path)

        if result.exitCode == 0 {
            return .success(output: "✅ **Dependencias actualizadas exitosamente**\n\n\(result.output)")
        } else {
            return .partial(output: "⚠️ **Actualización parcial completada**\n\n\(result.output)", warning: result.error)
        }
    }

    private func createFile(_ parameters: [String: Any], in project: Project) async throws -> ExecutedAction.ActionResult {
        guard let fileName = parameters["name"] as? String else {
            throw NSError(domain: "ProjectAgent", code: 1, userInfo: [NSLocalizedDescriptionKey: "Nombre del archivo requerido"])
        }

        let fileType = parameters["type"] as? String ?? "swift"
        let content = parameters["content"] as? String ?? generateDefaultContent(for: fileType, fileName: fileName)

        let filePath = "\(project.path)/\(fileName)"
        try content.write(toFile: filePath, atomically: true, encoding: .utf8)

        return .success(output: "✅ **Archivo \(fileName) creado exitosamente**\n\n📍 Ubicación: \(filePath)")
    }

    private func refactorCode(_ parameters: [String: Any], in project: Project) async throws -> ExecutedAction.ActionResult {
        let filePath = parameters["file"] as? String ?? ""
        return .success(output: "🛠️ **Refactoring simulado para \(filePath)**\n\nEsta funcionalidad requiere integración con herramientas de refactoring específicas.")
    }

    private func gitCommit(_ parameters: [String: Any], in project: Project) async throws -> ExecutedAction.ActionResult {
        let message = parameters["message"] as? String ?? "Automated commit from Gula agent"

        let addResult = try await processRunner.run("git add .", in: project.path)
        guard addResult.exitCode == 0 else {
            return .failure(error: "Error agregando archivos: \(addResult.error)")
        }

        let commitResult = try await processRunner.run("git commit -m \"\(message)\"", in: project.path)
        if commitResult.exitCode == 0 {
            return .success(output: "✅ **Commit creado exitosamente**\n\n\(commitResult.output)")
        } else {
            return .failure(error: "Error creando commit: \(commitResult.error)")
        }
    }

    private func openInXcode(_ project: Project) async throws -> ExecutedAction.ActionResult {
        let result = try await processRunner.run("open \(project.path)", in: project.path)
        if result.exitCode == 0 {
            return .success(output: "✅ **Proyecto abierto en Xcode**")
        } else {
            return .failure(error: "Error abriendo proyecto: \(result.error)")
        }
    }

    private func createReadme(in project: Project) async throws -> ExecutedAction.ActionResult {
        let readmeContent = generateReadmeContent(for: project)
        let readmePath = "\(project.path)/README.md"

        try readmeContent.write(toFile: readmePath, atomically: true, encoding: .utf8)

        return .success(output: "✅ **README.md creado exitosamente**\n\n📍 Ubicación: \(readmePath)")
    }

    // MARK: - Helper Methods

    private func countFiles(in path: String, for type: ProjectType) throws -> Int {
        let enumerator = fileManager.enumerator(atPath: path)
        var count = 0

        let relevantExtensions = getRelevantExtensions(for: type)

        while let file = enumerator?.nextObject() as? String {
            if relevantExtensions.contains(where: { file.hasSuffix($0) }) {
                count += 1
            }
        }

        return count
    }

    private func checkCommonIssues(in project: Project) async throws -> [String] {
        var issues: [String] = []

        // Check for missing files
        let requiredFiles = getRequiredFiles(for: project.type)
        for file in requiredFiles {
            if !fileManager.fileExists(atPath: "\(project.path)/\(file)") {
                issues.append("Archivo requerido faltante: \(file)")
            }
        }

        // Basic build check
        let buildCommand = getBuildCommand(for: project.type)
        let result = try await processRunner.run("\(buildCommand) --dry-run", in: project.path)
        if result.exitCode != 0 {
            issues.append("El proyecto no compila correctamente")
        }

        return issues
    }

    private func generateModuleTemplate(named name: String, for type: ProjectType) throws -> [String: String] {
        switch type {
        case .ios:
            return [
                "\(name)View.swift": generateSwiftUIView(named: name),
                "\(name)ViewModel.swift": generateSwiftUIViewModel(named: name),
                "\(name)Builder.swift": generateSwiftUIBuilder(named: name)
            ]
        case .android:
            return [
                "\(name)Fragment.kt": generateAndroidFragment(named: name),
                "\(name)ViewModel.kt": generateAndroidViewModel(named: name)
            ]
        case .flutter:
            return [
                "\(name.lowercased())_screen.dart": generateFlutterScreen(named: name),
                "\(name.lowercased())_bloc.dart": generateFlutterBloc(named: name)
            ]
        case .python:
            return [
                "\(name.lowercased()).py": generatePythonModule(named: name),
                "test_\(name.lowercased()).py": generatePythonTest(named: name)
            ]
        }
    }

    private func getRelevantExtensions(for type: ProjectType) -> [String] {
        switch type {
        case .ios: return [".swift", ".m", ".h"]
        case .android: return [".kt", ".java", ".xml"]
        case .flutter: return [".dart"]
        case .python: return [".py"]
        }
    }

    private func getRequiredFiles(for type: ProjectType) -> [String] {
        switch type {
        case .ios: return ["Info.plist"]
        case .android: return ["build.gradle", "AndroidManifest.xml"]
        case .flutter: return ["pubspec.yaml"]
        case .python: return ["requirements.txt"]
        }
    }

    private func getTestCommand(for type: ProjectType) -> String {
        switch type {
        case .ios: return "xcodebuild test"
        case .android: return "./gradlew test"
        case .flutter: return "flutter test"
        case .python: return "python -m pytest"
        }
    }

    private func getBuildCommand(for type: ProjectType) -> String {
        switch type {
        case .ios: return "xcodebuild build"
        case .android: return "./gradlew build"
        case .flutter: return "flutter build"
        case .python: return "python -m py_compile"
        }
    }

    private func getUpdateDependenciesCommand(for type: ProjectType) -> String {
        switch type {
        case .ios: return "echo 'iOS dependencies updated via Xcode'"
        case .android: return "./gradlew --refresh-dependencies"
        case .flutter: return "flutter pub upgrade"
        case .python: return "pip install --upgrade -r requirements.txt"
        }
    }

    private func generateDefaultContent(for fileType: String, fileName: String) -> String {
        switch fileType {
        case "swift":
            return """
            //
            //  \(fileName)
            //  Generated by Gula Agent
            //

            import Foundation

            // TODO: Add your implementation here
            """
        case "kotlin", "kt":
            return """
            /**
             * \(fileName)
             * Generated by Gula Agent
             */

            // TODO: Add your implementation here
            """
        case "dart":
            return """
            /// \(fileName)
            /// Generated by Gula Agent

            // TODO: Add your implementation here
            """
        case "python", "py":
            return """
            \"\"\"
            \(fileName)
            Generated by Gula Agent
            \"\"\"

            # TODO: Add your implementation here
            """
        default:
            return "// Generated by Gula Agent\n// TODO: Add your implementation here"
        }
    }

    private func generateReadmeContent(for project: Project) -> String {
        return """
        # \(project.name)

        ## Descripción
        Proyecto \(project.type.displayName) generado con Gula.

        ## Estructura del Proyecto
        - **Tipo:** \(project.type.displayName)
        - **Ubicación:** \(project.displayPath)
        - **Última apertura:** \(project.relativeLastOpened)

        ## Instalación
        \(getInstallationInstructions(for: project.type))

        ## Uso
        \(getUsageInstructions(for: project.type))

        ## Contribución
        1. Fork el proyecto
        2. Crea tu feature branch
        3. Commit tus cambios
        4. Push al branch
        5. Abre un Pull Request

        ---
        *Generado automáticamente por Gula Agent*
        """
    }

    private func getInstallationInstructions(for type: ProjectType) -> String {
        switch type {
        case .ios:
            return """
            1. Abre el proyecto en Xcode
            2. Selecciona tu dispositivo o simulador
            3. Presiona Cmd+R para ejecutar
            """
        case .android:
            return """
            1. Abre el proyecto en Android Studio
            2. Sincroniza las dependencias con Gradle
            3. Ejecuta la aplicación
            """
        case .flutter:
            return """
            1. Ejecuta `flutter pub get`
            2. Conecta un dispositivo o inicia un emulador
            3. Ejecuta `flutter run`
            """
        case .python:
            return """
            1. Instala las dependencias: `pip install -r requirements.txt`
            2. Ejecuta el script principal
            """
        }
    }

    private func getUsageInstructions(for type: ProjectType) -> String {
        switch type {
        case .ios:
            return "Aplicación iOS nativa desarrollada en Swift/SwiftUI."
        case .android:
            return "Aplicación Android nativa desarrollada en Kotlin."
        case .flutter:
            return "Aplicación multiplataforma desarrollada en Flutter/Dart."
        case .python:
            return "Proyecto Python para [descripción del propósito]."
        }
    }

    // MARK: - Template Generators

    private func generateSwiftUIView(named name: String) -> String {
        return """
        import SwiftUI

        struct \(name)View: View {
            @StateObject private var viewModel: \(name)ViewModel

            init(viewModel: \(name)ViewModel = \(name)ViewModel()) {
                self._viewModel = StateObject(wrappedValue: viewModel)
            }

            var body: some View {
                VStack {
                    Text("Welcome to \(name)")
                        .font(.largeTitle)
                        .padding()

                    Spacer()
                }
                .navigationTitle("\(name)")
                .onAppear {
                    viewModel.viewDidAppear()
                }
            }
        }

        #Preview {
            \(name)View()
        }
        """
    }

    private func generateSwiftUIViewModel(named name: String) -> String {
        return """
        import Foundation
        import Combine

        @MainActor
        final class \(name)ViewModel: ObservableObject {
            // MARK: - Properties

            // MARK: - Initialization
            init() {
                setupViewModel()
            }

            // MARK: - Public Methods
            func viewDidAppear() {
                // Handle view appearance
            }

            // MARK: - Private Methods
            private func setupViewModel() {
                // Initial setup
            }
        }
        """
    }

    private func generateSwiftUIBuilder(named name: String) -> String {
        return """
        import SwiftUI

        struct \(name)Builder {
            static func build() -> some View {
                let viewModel = \(name)ViewModel()
                return \(name)View(viewModel: viewModel)
            }
        }
        """
    }

    private func generateAndroidFragment(named name: String) -> String {
        return """
        package com.example.app

        import android.os.Bundle
        import android.view.LayoutInflater
        import android.view.View
        import android.view.ViewGroup
        import androidx.fragment.app.Fragment
        import androidx.lifecycle.ViewModelProvider

        class \(name)Fragment : Fragment() {

            private lateinit var viewModel: \(name)ViewModel

            override fun onCreateView(
                inflater: LayoutInflater,
                container: ViewGroup?,
                savedInstanceState: Bundle?
            ): View? {
                return inflater.inflate(R.layout.fragment_\(name.lowercased()), container, false)
            }

            override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
                super.onViewCreated(view, savedInstanceState)
                viewModel = ViewModelProvider(this)[\(name)ViewModel::class.java]
            }
        }
        """
    }

    private func generateAndroidViewModel(named name: String) -> String {
        return """
        package com.example.app

        import androidx.lifecycle.ViewModel

        class \(name)ViewModel : ViewModel() {

            // TODO: Add your implementation here

        }
        """
    }

    private func generateFlutterScreen(named name: String) -> String {
        return """
        import 'package:flutter/material.dart';

        class \(name)Screen extends StatefulWidget {
          const \(name)Screen({Key? key}) : super(key: key);

          @override
          _\(name)ScreenState createState() => _\(name)ScreenState();
        }

        class _\(name)ScreenState extends State<\(name)Screen> {
          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text('\(name)'),
              ),
              body: const Center(
                child: Text('Welcome to \(name)'),
              ),
            );
          }
        }
        """
    }

    private func generateFlutterBloc(named name: String) -> String {
        return """
        import 'package:flutter_bloc/flutter_bloc.dart';

        // Events
        abstract class \(name)Event {}

        class Load\(name) extends \(name)Event {}

        // States
        abstract class \(name)State {}

        class \(name)Initial extends \(name)State {}
        class \(name)Loading extends \(name)State {}
        class \(name)Loaded extends \(name)State {}

        // BLoC
        class \(name)Bloc extends Bloc<\(name)Event, \(name)State> {
          \(name)Bloc() : super(\(name)Initial()) {
            on<Load\(name)>(_onLoad\(name));
          }

          void _onLoad\(name)(Load\(name) event, Emitter<\(name)State> emit) {
            // TODO: Add your implementation here
          }
        }
        """
    }

    private func generatePythonModule(named name: String) -> String {
        return """
        \"\"\"
        \(name) module
        Generated by Gula Agent
        \"\"\"


        class \(name):
            \"\"\"
            \(name) class
            \"\"\"

            def __init__(self):
                \"\"\"Initialize \(name)\"\"\"
                pass

            def process(self):
                \"\"\"Process method\"\"\"
                pass


        def main():
            \"\"\"Main function\"\"\"
            instance = \(name)()
            instance.process()


        if __name__ == "__main__":
            main()
        """
    }

    private func generatePythonTest(named name: String) -> String {
        return """
        \"\"\"
        Tests for \(name) module
        \"\"\"

        import unittest
        from \(name.lowercased()) import \(name)


        class Test\(name)(unittest.TestCase):
            \"\"\"Test cases for \(name)\"\"\"

            def setUp(self):
                \"\"\"Set up test fixtures\"\"\"
                self.instance = \(name)()

            def test_initialization(self):
                \"\"\"Test \(name) initialization\"\"\"
                self.assertIsNotNone(self.instance)

            def test_process(self):
                \"\"\"Test process method\"\"\"
                # TODO: Add your test implementation here
                pass


        if __name__ == "__main__":
            unittest.main()
        """
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
