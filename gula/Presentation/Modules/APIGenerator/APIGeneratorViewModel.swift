import Foundation

// Import the OpenAPI models - assuming they are in the same module

@MainActor
@Observable
class APIGeneratorViewModel {
    var isLoading = false
    var generatedFiles: [GeneratedFile] = []
    var errorMessage: String?
    
    private let apiService = APIGeneratorService()
    private let fileManager = FileManager.default
    
    func generateDTOsOnly(
        from openAPIUrl: String,
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
            
            // 3. Generate DTOs with endpoint associations
            let dtoFiles: [GeneratedFile]
            if let schemas = parsedAPI.components?.schemas {
                dtoFiles = try await generateDTOsWithEndpointInfo(from: schemas, paths: parsedAPI.paths)
            } else {
                dtoFiles = []
            }
            
            // 4. Update UI
            generatedFiles = dtoFiles
            
            // 5. Optionally save to project
            // try await saveToProject(files: dtoFiles, projectPath: projectPath)
            
        } catch {
            errorMessage = "Error generando DTOs: \(error.localizedDescription)"
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
    
    
    // MARK: - DTO Generation
    
    private func generateDTOs(from schemas: [String: Box<OpenAPISchema>]) async throws -> [GeneratedFile] {
        var files: [GeneratedFile] = []
        
        for (name, schema) in schemas {
            let dtoContent = generateDTOContent(name: name, schema: schema.value)
            
            files.append(GeneratedFile(
                fileName: "\(name).swift",
                path: "Network/DTOs/\(name).swift",
                content: dtoContent,
                type: .dto,
                endpointPath: nil, // Los DTOs son esquemas globales
                httpMethod: nil
            ))
        }
        
        return files
    }
    
    // Nueva función que asocia DTOs con endpoints
    private func generateDTOsWithEndpointInfo(from schemas: [String: Box<OpenAPISchema>], paths: [String: OpenAPIPath]) async throws -> [GeneratedFile] {
        var files: [GeneratedFile] = []
        let schemaUsage = analyzeSchemaUsage(in: paths)
        
        for (name, schema) in schemas {
            let dtoContent = generateDTOContent(name: name, schema: schema.value)
            let usage = schemaUsage[name]
            
            files.append(GeneratedFile(
                fileName: "\(name).swift",
                path: "Network/DTOs/\(name).swift",
                content: dtoContent,
                type: .dto,
                endpointPath: usage?.endpoint,
                httpMethod: usage?.method
            ))
        }
        
        return files
    }
    
    // Estructura para rastrear el uso de schemas
    private struct SchemaUsage {
        let endpoint: String
        let method: String
        let usageType: String // "request" o "response"
    }
    
    // Analiza en qué endpoints se usan los schemas
    private func analyzeSchemaUsage(in paths: [String: OpenAPIPath]) -> [String: SchemaUsage] {
        var usage: [String: SchemaUsage] = [:]
        
        for (path, pathItem) in paths {
            let operations: [(String, OpenAPIOperation?)] = [
                ("GET", pathItem.get),
                ("POST", pathItem.post),
                ("PUT", pathItem.put),
                ("DELETE", pathItem.delete),
                ("PATCH", pathItem.patch)
            ]
            
            for (method, operation) in operations {
                guard let op = operation else { continue }
                
                // Analizar schemas en responses
                for (_, response) in op.responses {
                    if let content = response.content {
                        for (_, mediaTypeObj) in content {
                            if let schemaRef = extractSchemaReference(from: mediaTypeObj.schema) {
                                usage[schemaRef] = SchemaUsage(
                                    endpoint: path,
                                    method: method,
                                    usageType: "response"
                                )
                            }
                        }
                    }
                }
                
                // Analizar schemas en request body
                if let requestBody = op.requestBody {
                    for (_, mediaTypeObj) in requestBody.content {
                        if let schemaRef = extractSchemaReference(from: mediaTypeObj.schema) {
                            usage[schemaRef] = SchemaUsage(
                                endpoint: path,
                                method: method,
                                usageType: "request"
                            )
                        }
                    }
                }
            }
        }
        
        return usage
    }
    
    // Extrae el nombre del schema desde una referencia
    private func extractSchemaReference(from schema: Box<OpenAPISchema>?) -> String? {
        guard let schema = schema?.value else { return nil }
        
        // Buscar referencia como "#/components/schemas/NombreDelSchema"
        if let ref = schema.ref {
            let components = ref.components(separatedBy: "/")
            return components.last
        }
        
        return nil
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
    
    // MARK: - Helper Methods for Type Conversion
    
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