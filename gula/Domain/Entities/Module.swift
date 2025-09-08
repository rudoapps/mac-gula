import Foundation

struct Module: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let displayName: String
    let description: String
    let category: ModuleCategory
    let icon: String
    
    init(name: String, displayName: String, description: String, category: ModuleCategory, icon: String = "cube.box") {
        self.name = name
        self.displayName = displayName
        self.description = description
        self.category = category
        self.icon = icon
    }
}

enum ModuleCategory: String, CaseIterable {
    case authentication = "AUTENTICACIÓN Y SEGURIDAD"
    case networking = "NETWORKING Y API"
    case database = "BASE DE DATOS"
    case ui = "UI COMPONENTS"
    case analytics = "ANALYTICS Y TRACKING"
    case utilities = "UTILIDADES"
    
    var icon: String {
        switch self {
        case .authentication:
            return "lock.shield"
        case .networking:
            return "network"
        case .database:
            return "externaldrive"
        case .ui:
            return "paintbrush"
        case .analytics:
            return "chart.bar"
        case .utilities:
            return "wrench.and.screwdriver"
        }
    }
    
    var color: String {
        switch self {
        case .authentication:
            return "blue"
        case .networking:
            return "green"
        case .database:
            return "orange"
        case .ui:
            return "purple"
        case .analytics:
            return "pink"
        case .utilities:
            return "gray"
        }
    }
}

extension Module {
    static func parseFromGulaOutput(_ output: String) -> [Module] {
        let lines = output.components(separatedBy: .newlines)
        var modules: [Module] = []
        var currentCategory: ModuleCategory?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Detect category headers
            for category in ModuleCategory.allCases {
                if trimmedLine.contains(category.rawValue) {
                    currentCategory = category
                    break
                }
            }
            
            // Parse module lines (start with •)
            if trimmedLine.hasPrefix("•"), let category = currentCategory {
                let moduleInfo = trimmedLine.dropFirst().trimmingCharacters(in: .whitespaces)
                let components = moduleInfo.components(separatedBy: " - ")
                
                if components.count >= 2 {
                    let name = components[0].trimmingCharacters(in: .whitespaces)
                    let description = components[1].trimmingCharacters(in: .whitespaces)
                    let displayName = name.replacingOccurrences(of: "_", with: " ").capitalized
                    
                    let module = Module(
                        name: name,
                        displayName: displayName,
                        description: description,
                        category: category,
                        icon: category.icon
                    )
                    modules.append(module)
                }
            }
        }
        
        return modules
    }
}