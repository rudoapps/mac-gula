import Foundation

struct Template: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let displayName: String
    let description: String
    let category: TemplateCategory
    let icon: String
    let supportedTypes: [TemplateType]
    
    init(name: String, displayName: String, description: String, category: TemplateCategory, icon: String = "doc.text", supportedTypes: [TemplateType] = [.clean]) {
        self.name = name
        self.displayName = displayName
        self.description = description
        self.category = category
        self.icon = icon
        self.supportedTypes = supportedTypes
    }
}

enum TemplateCategory: String, CaseIterable {
    case components = "COMPONENTES UI"
    case authentication = "AUTENTICACIÓN"
    case commerce = "COMERCIO"
    case reports = "REPORTES"
    case utilities = "UTILIDADES"
    
    var icon: String {
        switch self {
        case .components:
            return "rectangle.3.offgrid"
        case .authentication:
            return "lock.shield"
        case .commerce:
            return "creditcard"
        case .reports:
            return "chart.bar"
        case .utilities:
            return "wrench.and.screwdriver"
        }
    }
    
    var color: String {
        switch self {
        case .components:
            return "blue"
        case .authentication:
            return "red"
        case .commerce:
            return "green"
        case .reports:
            return "purple"
        case .utilities:
            return "orange"
        }
    }
}

enum TemplateType: String, CaseIterable {
    case clean = "clean"
    case fastapi = "fastapi"
    
    var displayName: String {
        switch self {
        case .clean:
            return "Clean Architecture"
        case .fastapi:
            return "FastAPI"
        }
    }
    
    var description: String {
        switch self {
        case .clean:
            return "Arquitectura limpia con separación de capas"
        case .fastapi:
            return "API REST con FastAPI framework"
        }
    }
    
    var icon: String {
        switch self {
        case .clean:
            return "layers.alt"
        case .fastapi:
            return "server.rack"
        }
    }
}

extension Template {
    static func parseFromGulaOutput(_ output: String) -> [Template] {
        let lines = output.components(separatedBy: .newlines)
        var templates: [Template] = []
        var currentCategory: TemplateCategory?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Detect category headers
            for category in TemplateCategory.allCases {
                if trimmedLine.contains(category.rawValue) {
                    currentCategory = category
                    break
                }
            }
            
            // Parse template lines (start with •)
            if trimmedLine.hasPrefix("•"), let category = currentCategory {
                let templateInfo = trimmedLine.dropFirst().trimmingCharacters(in: .whitespaces)
                let components = templateInfo.components(separatedBy: " - ")
                
                if components.count >= 2 {
                    let name = components[0].trimmingCharacters(in: .whitespaces)
                    let description = components[1].trimmingCharacters(in: .whitespaces)
                    let displayName = name.replacingOccurrences(of: "_", with: " ").capitalized
                    
                    let template = Template(
                        name: name,
                        displayName: displayName,
                        description: description,
                        category: category,
                        icon: category.icon,
                        supportedTypes: [.clean, .fastapi]
                    )
                    templates.append(template)
                }
            }
        }
        
        return templates
    }
    
    // Templates predefinidos para cuando no se puede ejecutar el comando
    static let sampleTemplates: [Template] = [
        // Componentes UI
        Template(name: "user", displayName: "User", description: "Gestión de usuarios (CRUD completo)", category: .components, icon: "person.circle", supportedTypes: [.clean, .fastapi]),
        Template(name: "product", displayName: "Product", description: "Gestión de productos (CRUD completo)", category: .components, icon: "cube.box", supportedTypes: [.clean, .fastapi]),
        Template(name: "order", displayName: "Order", description: "Gestión de pedidos (CRUD completo)", category: .components, icon: "doc.text", supportedTypes: [.clean, .fastapi]),
        Template(name: "category", displayName: "Category", description: "Gestión de categorías (CRUD completo)", category: .components, icon: "folder", supportedTypes: [.clean, .fastapi]),
        
        // Autenticación
        Template(name: "auth", displayName: "Auth", description: "Sistema de autenticación completo", category: .authentication, icon: "lock.shield", supportedTypes: [.clean, .fastapi]),
        Template(name: "profile", displayName: "Profile", description: "Perfil de usuario editable", category: .authentication, icon: "person.crop.circle", supportedTypes: [.clean]),
        
        // Comercio
        Template(name: "payment", displayName: "Payment", description: "Procesamiento de pagos", category: .commerce, icon: "creditcard", supportedTypes: [.clean, .fastapi]),
        Template(name: "cart", displayName: "Cart", description: "Carrito de compras", category: .commerce, icon: "cart", supportedTypes: [.clean]),
        
        // Reportes
        Template(name: "analytics", displayName: "Analytics", description: "Dashboard de analytics", category: .reports, icon: "chart.bar", supportedTypes: [.clean, .fastapi]),
        Template(name: "reports", displayName: "Reports", description: "Generador de reportes", category: .reports, icon: "doc.plaintext", supportedTypes: [.clean, .fastapi]),
        
        // Utilidades
        Template(name: "settings", displayName: "Settings", description: "Pantalla de configuración", category: .utilities, icon: "gearshape", supportedTypes: [.clean]),
        Template(name: "notifications", displayName: "Notifications", description: "Sistema de notificaciones", category: .utilities, icon: "bell", supportedTypes: [.clean, .fastapi])
    ]
}