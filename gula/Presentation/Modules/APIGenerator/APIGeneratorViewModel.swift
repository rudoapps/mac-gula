import Foundation
import Combine

// Import the OpenAPI models - assuming they are in the same module

@MainActor
class APIGeneratorViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var generatedFiles: [GeneratedFile] = []
    @Published var errorMessage: String?
    
    private let apiService = APIGeneratorService()
    private let fileManager = FileManager.default
    
    func generateAPI(
        from openAPIUrl: String,
        framework: NetworkingFramework,
        architecture: Architecture,
        projectType: ProjectType,
        projectPath: String
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Fetch OpenAPI specification
            let openAPISpec = try await fetchOpenAPISpec(from: openAPIUrl)
            
            // 2. Parse the specification
            let parsedAPI = try await parseOpenAPISpec(openAPISpec)
            
            // 3. Generate code based on configuration
            let generatedCode = try await generateCode(
                from: parsedAPI,
                framework: framework,
                architecture: architecture,
                projectType: projectType
            )
            
            // 4. Update UI
            generatedFiles = generatedCode
            
            // 5. Optionally save to project
            // try await saveToProject(files: generatedCode, projectPath: projectPath)
            
        } catch {
            errorMessage = "Error generando API: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func fetchOpenAPISpec(from url: String) async throws -> OpenAPISpec {
        guard let url = URL(string: url) else {
            throw APIGeneratorError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(OpenAPISpec.self, from: data)
    }
    
    private func parseOpenAPISpec(_ spec: OpenAPISpec) async throws -> ParsedAPI {
        return ParsedAPI(
            info: spec.info,
            servers: spec.servers ?? [],
            paths: spec.paths,
            components: spec.components
        )
    }
    
    private func generateCode(
        from api: ParsedAPI,
        framework: NetworkingFramework,
        architecture: Architecture,
        projectType: ProjectType
    ) async throws -> [GeneratedFile] {
        
        var files: [GeneratedFile] = []
        
        // Generate DTOs
        let dtoFiles: [GeneratedFile]
        if let schemas = api.components?.schemas {
            dtoFiles = try await generateDTOs(from: schemas)
        } else {
            dtoFiles = []
        }
        files.append(contentsOf: dtoFiles)
        
        // Generate Services
        let serviceFiles = try await generateServices(from: api.paths, framework: framework)
        files.append(contentsOf: serviceFiles)
        
        // Generate Repositories (if Clean Architecture)
        if architecture == .cleanArchitecture {
            let repositoryFiles = try await generateRepositories(from: api.paths)
            files.append(contentsOf: repositoryFiles)
            
            let useCaseFiles = try await generateUseCases(from: api.paths)
            files.append(contentsOf: useCaseFiles)
        }
        
        return files
    }
    
    // MARK: - DTO Generation
    
    private func generateDTOs(from schemas: [String: Box<OpenAPISchema>]) async throws -> [GeneratedFile] {
        var files: [GeneratedFile] = []
        
        for (name, schema) in schemas {
            let dtoContent = generateDTOContent(name: name, schema: schema.value)
            
            files.append(GeneratedFile(
                fileName: "\(name).swift",
                path: "Network/DTOs/\(name).swift",
                content: dtoContent,
                type: .dto
            ))
        }
        
        return files
    }
    
    private func generateDTOContent(name: String, schema: OpenAPISchema) -> String {
        let properties = schema.properties ?? [:]
        let requiredFields = schema.required ?? []
        
        var content = """
        import Foundation
        
        // MARK: - \(name)
        
        struct \(name): Codable {
        """
        
        // Generate properties
        for (propertyName, propertySchema) in properties.sorted(by: { $0.key < $1.key }) {
            let swiftType = convertToSwiftType(propertySchema.value)
            let isOptional = !requiredFields.contains(propertyName)
            let swiftPropertyName = convertToSwiftPropertyName(propertyName)
            
            content += """
            
                let \(swiftPropertyName): \(swiftType)\(isOptional ? "?" : "")
            """
        }
        
        // Generate CodingKeys if needed
        let needsCodingKeys = properties.keys.contains { propertyName in
            convertToSwiftPropertyName(propertyName) != propertyName
        }
        
        if needsCodingKeys {
            content += """
            
            
                enum CodingKeys: String, CodingKey {
            """
            
            for (propertyName, _) in properties.sorted(by: { $0.key < $1.key }) {
                let swiftPropertyName = convertToSwiftPropertyName(propertyName)
                if swiftPropertyName != propertyName {
                    content += """
                    
                        case \(swiftPropertyName) = "\(propertyName)"
                    """
                } else {
                    content += """
                    
                        case \(swiftPropertyName)
                    """
                }
            }
            
            content += """
            
                }
            """
        }
        
        content += """
        
        }
        """
        
        return content
    }
    
    // MARK: - Service Generation
    
    private func generateServices(from paths: [String: OpenAPIPath], framework: NetworkingFramework) async throws -> [GeneratedFile] {
        var files: [GeneratedFile] = []
        
        // Group endpoints by tag or create a general service
        let groupedEndpoints = groupEndpointsByService(paths)
        
        for (serviceName, endpoints) in groupedEndpoints {
            let serviceContent = generateServiceContent(
                serviceName: serviceName,
                endpoints: endpoints,
                framework: framework
            )
            
            let file = GeneratedFile(
                fileName: "\(serviceName)Service.swift",
                path: "Network/Services/\(serviceName)Service.swift",
                content: serviceContent,
                type: .service
            )
            
            files.append(file)
        }
        
        return files
    }
    
    private func generateServiceContent(serviceName: String, endpoints: [(String, String, OpenAPIOperation)], framework: NetworkingFramework) -> String {
        var content = """
        import Foundation
        """
        
        switch framework {
        case .combine:
            content += "\nimport Combine"
        case .alamofire:
            content += "\nimport Alamofire"
        default:
            break
        }
        
        content += """
        
        // MARK: - \(serviceName) Service Protocol
        
        protocol \(serviceName)ServiceProtocol {
        """
        
        // Generate protocol methods
        for (path, method, operation) in endpoints {
            let methodName = generateMethodName(from: path, method: method, operation: operation)
            let parameters = generateMethodParameters(from: operation)
            let returnType = generateReturnType(from: operation, framework: framework)
            
            content += """
            
                func \(methodName)(\(parameters)) async throws -> \(returnType)
            """
        }
        
        content += """
        
        }
        
        // MARK: - \(serviceName) Service Implementation
        
        class \(serviceName)Service: \(serviceName)ServiceProtocol {
            private let baseURL = "https://services.rudo.es"
            private let session = URLSession.shared
            
        """
        
        // Generate method implementations
        for (path, method, operation) in endpoints {
            let methodName = generateMethodName(from: path, method: method, operation: operation)
            let parameters = generateMethodParameters(from: operation)
            let returnType = generateReturnType(from: operation, framework: framework)
            let implementation = generateMethodImplementation(
                path: path,
                method: method,
                operation: operation,
                framework: framework
            )
            
            content += """
            
                func \(methodName)(\(parameters)) async throws -> \(returnType) {
            \(implementation)
                }
            """
        }
        
        content += """
        
        }
        """
        
        return content
    }
    
    // MARK: - Repository Generation (Clean Architecture)
    
    private func generateRepositories(from paths: [String: OpenAPIPath]) async throws -> [GeneratedFile] {
        var files: [GeneratedFile] = []
        
        let groupedEndpoints = groupEndpointsByService(paths)
        
        for (serviceName, endpoints) in groupedEndpoints {
            let repositoryContent = generateRepositoryContent(serviceName: serviceName, endpoints: endpoints)
            
            let file = GeneratedFile(
                fileName: "\(serviceName)Repository.swift",
                path: "Data/Repositories/\(serviceName)Repository.swift",
                content: repositoryContent,
                type: .repository
            )
            
            files.append(file)
        }
        
        return files
    }
    
    private func generateRepositoryContent(serviceName: String, endpoints: [(String, String, OpenAPIOperation)]) -> String {
        return """
        import Foundation
        
        // MARK: - \(serviceName) Repository Protocol
        
        protocol \(serviceName)RepositoryProtocol {
            // Repository methods will be generated here based on endpoints
        }
        
        // MARK: - \(serviceName) Repository Implementation
        
        class \(serviceName)RepositoryImpl: \(serviceName)RepositoryProtocol {
            private let service: \(serviceName)ServiceProtocol
            
            init(service: \(serviceName)ServiceProtocol) {
                self.service = service
            }
            
            // Implementation methods will be generated here
        }
        """
    }
    
    // MARK: - Use Case Generation
    
    private func generateUseCases(from paths: [String: OpenAPIPath]) async throws -> [GeneratedFile] {
        var files: [GeneratedFile] = []
        
        let groupedEndpoints = groupEndpointsByService(paths)
        
        for (serviceName, endpoints) in groupedEndpoints {
            for (path, method, operation) in endpoints {
                let useCaseName = generateUseCaseName(from: path, method: method, operation: operation)
                let useCaseContent = generateUseCaseContent(
                    name: useCaseName,
                    serviceName: serviceName,
                    operation: operation
                )
                
                let file = GeneratedFile(
                    fileName: "\(useCaseName)UseCase.swift",
                    path: "Domain/UseCases/\(useCaseName)UseCase.swift",
                    content: useCaseContent,
                    type: .useCase
                )
                
                files.append(file)
            }
        }
        
        return files
    }
    
    private func generateUseCaseContent(name: String, serviceName: String, operation: OpenAPIOperation) -> String {
        return """
        import Foundation
        
        // MARK: - \(name) Use Case
        
        class \(name)UseCase {
            private let repository: \(serviceName)RepositoryProtocol
            
            init(repository: \(serviceName)RepositoryProtocol) {
                self.repository = repository
            }
            
            func execute() async throws {
                // Use case implementation will be generated here
            }
        }
        """
    }
    
    // MARK: - Helper Methods
    
    private func groupEndpointsByService(_ paths: [String: OpenAPIPath]) -> [String: [(String, String, OpenAPIOperation)]] {
        var grouped: [String: [(String, String, OpenAPIOperation)]] = [:]
        
        for (path, pathItem) in paths {
            let operations: [(String, OpenAPIOperation)] = [
                ("get", pathItem.get),
                ("post", pathItem.post),
                ("put", pathItem.put),
                ("delete", pathItem.delete),
                ("patch", pathItem.patch)
            ].compactMap { (method, operation) in
                guard let op = operation else { return nil }
                return (method, op)
            }
            
            for (method, operation) in operations {
                let serviceName = extractServiceName(from: path, operation: operation)
                if grouped[serviceName] == nil {
                    grouped[serviceName] = []
                }
                grouped[serviceName]?.append((path, method, operation))
            }
        }
        
        return grouped
    }
    
    private func extractServiceName(from path: String, operation: OpenAPIOperation) -> String {
        // Extract service name from path or tags
        if let tag = operation.tags?.first {
            return tag.capitalized
        }
        
        let components = path.components(separatedBy: "/").filter { !$0.isEmpty }
        if let firstComponent = components.first, firstComponent != "api" {
            return firstComponent.capitalized
        }
        
        return "API"
    }
    
    private func generateMethodName(from path: String, method: String, operation: OpenAPIOperation) -> String {
        if let operationId = operation.operationId {
            return convertToCamelCase(operationId)
        }
        
        let pathComponents = path.components(separatedBy: "/").filter { !$0.isEmpty && !$0.hasPrefix("{") }
        let lastComponent = pathComponents.last ?? "data"
        
        switch method.lowercased() {
        case "get":
            return "get\(lastComponent.capitalized)"
        case "post":
            return "create\(lastComponent.capitalized)"
        case "put":
            return "update\(lastComponent.capitalized)"
        case "delete":
            return "delete\(lastComponent.capitalized)"
        default:
            return "\(method.lowercased())\(lastComponent.capitalized)"
        }
    }
    
    private func generateMethodParameters(from operation: OpenAPIOperation) -> String {
        var parameters: [String] = []
        
        // Add path parameters
        if let pathParams = operation.parameters?.filter({ $0.in == "path" }) {
            for param in pathParams {
                let swiftType = convertToSwiftType(param.schema?.value)
                parameters.append("\(convertToCamelCase(param.name)): \(swiftType)")
            }
        }
        
        // Add query parameters
        if let queryParams = operation.parameters?.filter({ $0.in == "query" }) {
            for param in queryParams {
                let swiftType = convertToSwiftType(param.schema?.value)
                let isOptional = !(param.required ?? false)
                parameters.append("\(convertToCamelCase(param.name)): \(swiftType)\(isOptional ? "?" : "")")
            }
        }
        
        // Add request body
        if operation.requestBody != nil {
            parameters.append("request: Codable")
        }
        
        return parameters.joined(separator: ", ")
    }
    
    private func generateReturnType(from operation: OpenAPIOperation, framework: NetworkingFramework) -> String {
        // Simplified - in a real implementation, you'd parse the response schema
        return "Data"
    }
    
    private func generateMethodImplementation(path: String, method: String, operation: OpenAPIOperation, framework: NetworkingFramework) -> String {
        return """
                // Implementation for \(method.uppercased()) \(path)
                // TODO: Generate actual implementation based on framework
                return Data()
        """
    }
    
    private func generateUseCaseName(from path: String, method: String, operation: OpenAPIOperation) -> String {
        if let operationId = operation.operationId {
            return operationId.capitalized
        }
        
        let pathComponents = path.components(separatedBy: "/").filter { !$0.isEmpty && !$0.hasPrefix("{") }
        let resource = pathComponents.last?.capitalized ?? "Resource"
        
        switch method.lowercased() {
        case "get":
            return "Get\(resource)"
        case "post":
            return "Create\(resource)"
        case "put":
            return "Update\(resource)"
        case "delete":
            return "Delete\(resource)"
        default:
            return "\(method.capitalized)\(resource)"
        }
    }
    
    private func convertToSwiftType(_ schema: OpenAPISchema?) -> String {
        guard let schema = schema else { return "Any" }
        
        switch schema.type {
        case "string":
            return "String"
        case "integer":
            return "Int"
        case "number":
            return "Double"
        case "boolean":
            return "Bool"
        case "array":
            let itemType = convertToSwiftType(schema.items?.value)
            return "[\(itemType)]"
        case "object":
            return "Any" // Would need more sophisticated parsing
        default:
            return "Any"
        }
    }
    
    private func convertToSwiftPropertyName(_ name: String) -> String {
        return convertToCamelCase(name)
    }
    
    private func convertToCamelCase(_ string: String) -> String {
        let components = string.components(separatedBy: "_")
        guard let first = components.first else { return string }
        
        let rest = components.dropFirst().map { $0.capitalized }
        return ([first.lowercased()] + rest).joined()
    }
}

// MARK: - Errors

enum APIGeneratorError: LocalizedError {
    case invalidURL
    case parsingFailed
    case generationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL de OpenAPI inválida"
        case .parsingFailed:
            return "Error al parsear la especificación OpenAPI"
        case .generationFailed(let message):
            return "Error generando código: \(message)"
        }
    }
}