import Foundation

// MARK: - Supporting Types

struct GeneratedFile: Identifiable, Equatable {
    let id = UUID()
    let fileName: String
    let path: String
    let content: String
    let type: GeneratedFileType
    let endpointPath: String? // Para agrupar por endpoint
    let httpMethod: String? // GET, POST, etc.
    
    static func == (lhs: GeneratedFile, rhs: GeneratedFile) -> Bool {
        return lhs.id == rhs.id
    }
}

// Modelo para el preview con selección
@Observable
class SelectableGeneratedFile: Identifiable, Equatable {
    let id = UUID()
    let file: GeneratedFile
    var isSelected: Bool = false
    
    init(file: GeneratedFile, isSelected: Bool = false) {
        self.file = file
        self.isSelected = isSelected
    }
    
    static func == (lhs: SelectableGeneratedFile, rhs: SelectableGeneratedFile) -> Bool {
        return lhs.id == rhs.id
    }
}

enum GeneratedFileType: String, CaseIterable {
    case dto = "dto"
    case service = "service"
    case repository = "repository"
    case useCase = "useCase"
    case domainModel = "domainModel"
    
    var description: String {
        switch self {
        case .dto: return "Data Transfer Object"
        case .service: return "Network Service"
        case .repository: return "Repository"
        case .useCase: return "Use Case"
        case .domainModel: return "Domain Model"
        }
    }
    
    var icon: String {
        switch self {
        case .dto: return "doc.text"
        case .service: return "network"
        case .repository: return "folder"
        case .useCase: return "gearshape"
        case .domainModel: return "cube"
        }
    }
}

enum NetworkingFramework: String, CaseIterable {
    case urlSession = "URLSession"
    case alamofire = "Alamofire"

    var displayName: String {
        return rawValue
    }

    var icon: String {
        switch self {
        case .urlSession: return "network"
        case .alamofire: return "globe"
        }
    }
}

enum Architecture: String, CaseIterable {
    case simple = "simple"
    case cleanArchitecture = "cleanArchitecture"
    case mvvm = "mvvm"
    case viper = "viper"
    
    var displayName: String {
        switch self {
        case .simple: return "Simple"
        case .cleanArchitecture: return "Clean Architecture"
        case .mvvm: return "MVVM"
        case .viper: return "VIPER"
        }
    }
    
    var icon: String {
        switch self {
        case .simple: return "square"
        case .cleanArchitecture: return "building.columns"
        case .mvvm: return "rectangle.3.group"
        case .viper: return "hexagon"
        }
    }
}