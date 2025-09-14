import Foundation

// MARK: - OpenAPI Specification Models

struct OpenAPISpec: Codable {
    let openapi: String
    let info: OpenAPIInfo
    let servers: [OpenAPIServer]?
    let paths: [String: OpenAPIPath]
    let components: OpenAPIComponents?
    let security: [OpenAPISecurity]?
    let tags: [OpenAPITag]?
}

// MARK: - Info

struct OpenAPIInfo: Codable {
    let title: String
    let version: String
    let description: String?
    let contact: OpenAPIContact?
    let license: OpenAPILicense?
}

struct OpenAPIContact: Codable {
    let name: String?
    let url: String?
    let email: String?
}

struct OpenAPILicense: Codable {
    let name: String
    let url: String?
}

// MARK: - Server

struct OpenAPIServer: Codable {
    let url: String
    let description: String?
    let variables: [String: OpenAPIServerVariable]?
}

struct OpenAPIServerVariable: Codable {
    let `enum`: [String]?
    let `default`: String
    let description: String?
}

// MARK: - Paths

struct OpenAPIPath: Codable {
    let get: OpenAPIOperation?
    let post: OpenAPIOperation?
    let put: OpenAPIOperation?
    let delete: OpenAPIOperation?
    let patch: OpenAPIOperation?
    let head: OpenAPIOperation?
    let options: OpenAPIOperation?
    let trace: OpenAPIOperation?
    let parameters: [OpenAPIParameter]?
}

// MARK: - Operation

struct OpenAPIOperation: Codable {
    let tags: [String]?
    let summary: String?
    let description: String?
    let operationId: String?
    let parameters: [OpenAPIParameter]?
    let requestBody: OpenAPIRequestBody?
    let responses: [String: OpenAPIResponse]
    let deprecated: Bool?
    let security: [OpenAPISecurity]?
}

// MARK: - Parameter

struct OpenAPIParameter: Codable {
    let name: String
    let `in`: String // "query", "header", "path", "cookie"
    let description: String?
    let required: Bool?
    let deprecated: Bool?
    let schema: Box<OpenAPISchema>?
    let style: String?
    let explode: Bool?
    let example: AnyCodable?
}

// MARK: - Request Body

struct OpenAPIRequestBody: Codable {
    let description: String?
    let content: [String: OpenAPIMediaType]
    let required: Bool?
}

struct OpenAPIMediaType: Codable {
    let schema: Box<OpenAPISchema>?
    let example: AnyCodable?
    let examples: [String: OpenAPIExample]?
    let encoding: [String: OpenAPIEncoding]?
}

struct OpenAPIExample: Codable {
    let summary: String?
    let description: String?
    let value: AnyCodable?
    let externalValue: String?
}

struct OpenAPIEncoding: Codable {
    let contentType: String?
    let headers: [String: OpenAPIHeader]?
    let style: String?
    let explode: Bool?
    let allowReserved: Bool?
}

struct OpenAPIHeader: Codable {
    let description: String?
    let required: Bool?
    let deprecated: Bool?
    let schema: Box<OpenAPISchema>?
    let style: String?
    let explode: Bool?
}

// MARK: - Response

struct OpenAPIResponse: Codable {
    let description: String
    let headers: [String: OpenAPIHeader]?
    let content: [String: OpenAPIMediaType]?
    let links: [String: OpenAPILink]?
}

struct OpenAPILink: Codable {
    let operationRef: String?
    let operationId: String?
    let parameters: [String: AnyCodable]?
    let requestBody: AnyCodable?
    let description: String?
    let server: OpenAPIServer?
}

// MARK: - Components

struct OpenAPIComponents: Codable {
    let schemas: [String: Box<OpenAPISchema>]?
    let responses: [String: OpenAPIResponse]?
    let parameters: [String: OpenAPIParameter]?
    let examples: [String: OpenAPIExample]?
    let requestBodies: [String: OpenAPIRequestBody]?
    let headers: [String: OpenAPIHeader]?
    let securitySchemes: [String: OpenAPISecurityScheme]?
    let links: [String: OpenAPILink]?
    let callbacks: [String: OpenAPICallback]?
}

// MARK: - Schema

struct OpenAPISchema: Codable {
    let type: String?
    let format: String?
    let title: String?
    let description: String?
    let `default`: AnyCodable?
    let example: AnyCodable?
    let `enum`: [AnyCodable]?
    
    // String validation
    let minLength: Int?
    let maxLength: Int?
    let pattern: String?
    
    // Number validation
    let minimum: Double?
    let maximum: Double?
    let exclusiveMinimum: Bool?
    let exclusiveMaximum: Bool?
    let multipleOf: Double?
    
    // Array validation
    let items: Box<OpenAPISchema>?
    let minItems: Int?
    let maxItems: Int?
    let uniqueItems: Bool?
    
    // Object validation
    let properties: [String: Box<OpenAPISchema>]?
    let required: [String]?
    let additionalProperties: AnyCodableOrBool?
    let minProperties: Int?
    let maxProperties: Int?
    
    // Composition
    let allOf: [Box<OpenAPISchema>]?
    let oneOf: [Box<OpenAPISchema>]?
    let anyOf: [Box<OpenAPISchema>]?
    let not: Box<OpenAPISchema>?
    
    // Reference
    let ref: String?
    
    // Metadata
    let nullable: Bool?
    let readOnly: Bool?
    let writeOnly: Bool?
    let deprecated: Bool?
    
    enum CodingKeys: String, CodingKey {
        case type, format, title, description, example, `enum`
        case minLength, maxLength, pattern
        case minimum, maximum, exclusiveMinimum, exclusiveMaximum, multipleOf
        case items, minItems, maxItems, uniqueItems
        case properties, required, additionalProperties, minProperties, maxProperties
        case allOf, oneOf, anyOf, not
        case nullable, readOnly, writeOnly, deprecated
        case ref = "$ref"
        case `default` = "default"
    }
}

// MARK: - Security

struct OpenAPISecurity: Codable {
    // This is typically a dictionary where keys are security scheme names
    // and values are arrays of scopes (for OAuth2)
    private let storage: [String: [String]]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.storage = try container.decode([String: [String]].self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}

struct OpenAPISecurityScheme: Codable {
    let type: String // "apiKey", "http", "oauth2", "openIdConnect"
    let description: String?
    
    // API Key
    let name: String?
    let `in`: String? // "query", "header", "cookie"
    
    // HTTP
    let scheme: String? // "basic", "bearer", etc.
    let bearerFormat: String?
    
    // OAuth2
    let flows: OpenAPIOAuthFlows?
    
    // OpenID Connect
    let openIdConnectUrl: String?
}

struct OpenAPIOAuthFlows: Codable {
    let implicit: OpenAPIOAuthFlow?
    let password: OpenAPIOAuthFlow?
    let clientCredentials: OpenAPIOAuthFlow?
    let authorizationCode: OpenAPIOAuthFlow?
}

struct OpenAPIOAuthFlow: Codable {
    let authorizationUrl: String?
    let tokenUrl: String?
    let refreshUrl: String?
    let scopes: [String: String]
}

// MARK: - Tag

struct OpenAPITag: Codable {
    let name: String
    let description: String?
    let externalDocs: OpenAPIExternalDocumentation?
}

struct OpenAPIExternalDocumentation: Codable {
    let description: String?
    let url: String
}

// MARK: - Callback

struct OpenAPICallback: Codable {
    // Callbacks are complex nested structures
    // Simplified implementation for now
    private let storage: [String: OpenAPIPath]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.storage = try container.decode([String: OpenAPIPath].self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}

// MARK: - Helper Types

// Box type to handle recursive references
final class Box<T>: Codable where T: Codable {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(T.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

indirect enum AnyCodableOrBool: Codable {
    case bool(Bool)
    case schema(OpenAPISchema)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let schemaValue = try? container.decode(OpenAPISchema.self) {
            self = .schema(schemaValue)
        } else {
            throw DecodingError.typeMismatch(
                AnyCodableOrBool.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Bool or Schema")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .bool(let value):
            try container.encode(value)
        case .schema(let value):
            try container.encode(value)
        }
    }
}

struct AnyCodable: Codable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = ()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map(\.value)
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues(\.value)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to decode AnyCodable"
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            let anyCodableArray = array.map(AnyCodable.init)
            try container.encode(anyCodableArray)
        case let dictionary as [String: Any]:
            let anyCodableDictionary = dictionary.mapValues(AnyCodable.init)
            try container.encode(anyCodableDictionary)
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Unable to encode AnyCodable"
                )
            )
        }
    }
}

// MARK: - Parsed API Model

struct ParsedAPI {
    let info: OpenAPIInfo
    let servers: [OpenAPIServer]
    let paths: [String: OpenAPIPath]
    let components: OpenAPIComponents?
}

// MARK: - Service for API Generation

class APIGeneratorService {
    // This class will contain the main logic for parsing and generating code
    // Implementation would go here
}

// MARK: - Extensions for Better Property Names

extension OpenAPISchema {
    var swiftTypeName: String {
        switch type {
        case "string": return "String"
        case "integer": return "Int"
        case "number": return format == "float" ? "Float" : "Double"
        case "boolean": return "Bool"
        case "array": return "[\(items?.value.swiftTypeName ?? "Any")]"
        case "object": return "Any" // Would need more sophisticated handling
        default: return "Any"
        }
    }
}