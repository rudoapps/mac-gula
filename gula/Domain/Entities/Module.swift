import Foundation

struct Module: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let displayName: String
    let description: String
    let category: ModuleCategory
    let icon: String
    var installationStatus: InstallationStatus
    
    init(name: String, displayName: String, description: String, category: ModuleCategory, icon: String = "cube.box", installationStatus: InstallationStatus = .notInstalled) {
        self.name = name
        self.displayName = displayName
        self.description = description
        self.category = category
        self.icon = icon
        self.installationStatus = installationStatus
    }
}

enum InstallationStatus: Hashable {
    case notInstalled
    case installing
    case installed
    case failed(String)
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
        
        print("DEBUG: Starting to parse \(lines.count) lines")
        
        // Find the start of module list
        var startIndex = -1
        var endIndex = -1
        
        // Look for "Lista de módulos disponibles:" header
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces).lowercased()
            
            // Find header
            if trimmedLine.contains("lista de módulos disponibles") || 
               (trimmedLine.contains("lista") && trimmedLine.contains("módulos")) {
                print("DEBUG: Found module list header at line \(index): '\(lines[index])'")
                
                // Look for the first separator after header
                for i in (index + 1)..<min(index + 5, lines.count) {
                    if lines[i].contains("-------") {
                        startIndex = i + 1
                        print("DEBUG: Found start separator at line \(i)")
                        break
                    }
                }
                break
            }
        }
        
        if startIndex == -1 {
            print("DEBUG: Could not find module list start")
            
            // Check if output contains git errors
            let outputLower = output.lowercased()
            if outputLower.contains("fatal:") {
                print("DEBUG: Output contains git fatal errors - module loading failed")
            } else {
                print("DEBUG: Output format may have changed - expected 'Lista de módulos disponibles'")
            }
            
            return modules
        }
        
        // Find the end separator
        for index in startIndex..<lines.count {
            if lines[index].contains("-------") {
                endIndex = index
                print("DEBUG: Found end separator at line \(index)")
                break
            }
        }
        
        if endIndex == -1 {
            endIndex = lines.count
            print("DEBUG: No end separator found, using end of file")
        }
        
        // Parse modules between separators
        for index in startIndex..<endIndex {
            let trimmedLine = lines[index].trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines
            if trimmedLine.isEmpty {
                continue
            }
            
            // Skip lines with ANSI color codes or special characters
            if trimmedLine.contains("❌") || trimmedLine.contains("✅") || 
               trimmedLine.contains("[1;32m") || trimmedLine.contains("\u{001B}[") {
                print("DEBUG: Skipping special line \(index): '\(trimmedLine)'")
                continue
            }
            
            // Clean any remaining ANSI codes
            let cleanModuleName = cleanANSICodes(from: trimmedLine)
                .replacingOccurrences(of: "-", with: "_") // Convert kebab-case to snake_case for internal use
            
            if !cleanModuleName.isEmpty {
                print("DEBUG: Adding module '\(cleanModuleName)' from line \(index)")
                
                // Generate display name from module name
                let displayName = cleanModuleName
                    .replacingOccurrences(of: "_", with: " ")
                    .replacingOccurrences(of: "-", with: " ")
                    .split(separator: " ")
                    .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
                    .joined(separator: " ")
                
                let category = determineCategory(for: cleanModuleName)
                let icon = determineIcon(for: cleanModuleName)
                let description = generateDescription(for: cleanModuleName)
                
                let module = Module(
                    name: trimmedLine, // Keep original name for API calls
                    displayName: displayName,
                    description: description,
                    category: category,
                    icon: icon
                )
                modules.append(module)
            }
        }
        
        print("DEBUG: Finished parsing, found \(modules.count) modules")
        return modules
    }
    
    private static func cleanANSICodes(from string: String) -> String {
        // Remove ANSI color codes and escape sequences
        let ansiPattern = "\\u001B\\[[0-9;]*[a-zA-Z]|\\[1;32m|\\[0m"
        do {
            let regex = try NSRegularExpression(pattern: ansiPattern, options: [])
            let range = NSRange(location: 0, length: string.utf16.count)
            let cleanString = regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "")
            return cleanString.trimmingCharacters(in: .whitespaces)
        } catch {
            // If regex fails, manually remove common ANSI codes
            return string
                .replacingOccurrences(of: "[1;32m", with: "")
                .replacingOccurrences(of: "[0m", with: "")
                .replacingOccurrences(of: "\u{001B}[1;32m", with: "")
                .replacingOccurrences(of: "\u{001B}[0m", with: "")
                .trimmingCharacters(in: .whitespaces)
        }
    }
    
    private static func determineCategory(for moduleName: String) -> ModuleCategory {
        let normalized = moduleName.lowercased().replacingOccurrences(of: "-", with: "_")
        switch normalized {
        case "authentication", "profile", "personal_data":
            return .authentication
        case "chatia", "chat", "walletstripe", "wallet", "stripe", "checkout", "notifications":
            return .networking
        case "product_catalog", "productcatalog", "establishmentselection", "filesystem", "order", "tracking":
            return .database
        case "mapsmanager", "directions", "locationmanager", "cameraandgallery":
            return .ui
        case "schedules", "uploadimages":
            return .analytics
        case "settings", "build_logic":
            return .utilities
        default:
            return .utilities
        }
    }
    
    private static func determineIcon(for moduleName: String) -> String {
        let normalized = moduleName.lowercased().replacingOccurrences(of: "-", with: "_")
        switch normalized {
        case "authentication":
            return "person.badge.key.fill"
        case "build_logic":
            return "hammer.fill"
        case "cameraandgallery":
            return "camera.fill"
        case "chatia", "chat":
            return "message.badge.fill"
        case "checkout":
            return "cart.circle.fill"
        case "directions":
            return "location.north.line.fill"
        case "establishmentselection":
            return "building.2.fill"
        case "filesystem":
            return "folder.fill"
        case "locationmanager":
            return "location.fill"
        case "mapsmanager":
            return "map.fill"
        case "notifications":
            return "bell.fill"
        case "order":
            return "list.clipboard.fill"
        case "productcatalog", "product_catalog":
            return "tag.fill"
        case "profile", "personal_data":
            return "person.circle.fill"
        case "schedules":
            return "calendar.circle.fill"
        case "stripe":
            return "creditcard.circle.fill"
        case "tracking":
            return "location.circle.fill"
        case "uploadimages":
            return "photo.badge.plus.fill"
        case "wallet", "walletstripe":
            return "creditcard.fill"
        case "settings":
            return "gearshape.fill"
        default:
            return "wrench.and.screwdriver.fill"
        }
    }
    
    private static func generateDescription(for moduleName: String) -> String {
        let normalized = moduleName.lowercased().replacingOccurrences(of: "-", with: "_")
        switch normalized {
        case "authentication":
            return "Sistema completo de autenticación con login, registro y gestión de sesiones"
        case "build_logic":
            return "Lógica de construcción y configuración del proyecto con Gradle y dependencias"
        case "cameraandgallery":
            return "Integración con cámara y galería de fotos con permisos y funciones avanzadas"
        case "chatia":
            return "Integración con servicios de inteligencia artificial para chat conversacional"
        case "chat":
            return "Sistema de mensajería y chat en tiempo real con soporte multimedia"
        case "checkout":
            return "Proceso completo de checkout con validación de datos y confirmación de compra"
        case "directions":
            return "Navegación y direcciones con mapas integrados para rutas optimizadas"
        case "establishmentselection":
            return "Selección y gestión de establecimientos con filtros y búsqueda avanzada"
        case "filesystem":
            return "Gestión completa de archivos, carga, descarga y organización de documentos"
        case "locationmanager":
            return "Gestión de ubicación GPS con permisos y seguimiento en tiempo real"
        case "mapsmanager":
            return "Integración completa con mapas, marcadores y visualización geográfica"
        case "notifications":
            return "Sistema de notificaciones push y locales con personalización avanzada"
        case "order":
            return "Gestión completa de pedidos con seguimiento de estados y historial"
        case "productcatalog", "product_catalog":
            return "Catálogo de productos con categorías, filtros y gestión de inventario"
        case "profile":
            return "Gestión de perfiles de usuario con edición y configuración personalizada"
        case "personal_data":
            return "Gestión de datos personales del usuario con privacidad y seguridad"
        case "schedules":
            return "Sistema de horarios y programación con calendario integrado"
        case "stripe":
            return "Integración avanzada con Stripe para procesamiento de pagos seguros"
        case "tracking":
            return "Sistema de seguimiento y rastreo en tiempo real con notificaciones"
        case "uploadimages":
            return "Carga y procesamiento de imágenes con compresión y filtros automáticos"
        case "wallet":
            return "Billetera digital con gestión de saldos y transacciones seguras"
        case "walletstripe":
            return "Integración con Stripe para pagos, billetera digital y transacciones seguras"
        case "settings":
            return "Configuración de la aplicación con preferencias de usuario personalizables"
        default:
            return "Módulo en desarrollo - Funcionalidad próximamente disponible"
        }
    }
}