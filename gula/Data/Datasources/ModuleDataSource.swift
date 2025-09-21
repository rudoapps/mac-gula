import Foundation
import SwiftUI

protocol ModuleDataSourceProtocol {
    func getAvailableModules() -> [Module]
}

@Observable
class ModuleDataSource: ModuleDataSourceProtocol {
    func getAvailableModules() -> [Module] {
        return [
            Module(
                name: "Authentication",
                displayName: "Authentication",
                description: "Sistema completo de autenticación con login, registro y gestión de sesiones",
                category: .authentication,
                icon: "person.badge.key.fill"
            ),
            Module(
                name: "ChatIA",
                displayName: "ChatIA",
                description: "Integración con servicios de inteligencia artificial para chat conversacional",
                category: .networking,
                icon: "message.badge.fill"
            ),
            Module(
                name: "Directions",
                displayName: "Directions",
                description: "Navegación y direcciones con mapas integrados para rutas optimizadas",
                category: .utilities,
                icon: "location.north.line.fill"
            ),
            Module(
                name: "EstablishmentSelection",
                displayName: "Establishment Selection",
                description: "Selección y gestión de establecimientos con filtros y búsqueda avanzada",
                category: .ui,
                icon: "building.2.fill"
            ),
            Module(
                name: "FileSystem",
                displayName: "File System",
                description: "Gestión completa de archivos, carga, descarga y organización de documentos",
                category: .utilities,
                icon: "folder.fill"
            ),
            Module(
                name: "LocationManager",
                displayName: "Location Manager",
                description: "Gestión de ubicación GPS con permisos y seguimiento en tiempo real",
                category: .utilities,
                icon: "location.fill"
            ),
            Module(
                name: "MapsManager",
                displayName: "Maps Manager",
                description: "Integración completa con mapas, marcadores y visualización geográfica",
                category: .ui,
                icon: "map.fill"
            ),
            Module(
                name: "Notifications",
                displayName: "Notifications",
                description: "Sistema de notificaciones push y locales con personalización avanzada",
                category: .utilities,
                icon: "bell.fill"
            ),
            Module(
                name: "ProductCatalog",
                displayName: "Product Catalog",
                description: "Catálogo de productos con categorías, filtros y gestión de inventario",
                category: .ui,
                icon: "tag.fill"
            ),
            Module(
                name: "Profile",
                displayName: "Profile",
                description: "Gestión de perfiles de usuario con edición y configuración personalizada",
                category: .authentication,
                icon: "person.circle.fill"
            ),
            Module(
                name: "Schedules",
                displayName: "Schedules",
                description: "Sistema de horarios y programación con calendario integrado",
                category: .utilities,
                icon: "calendar.circle.fill"
            ),
            Module(
                name: "UploadImages",
                displayName: "Upload Images",
                description: "Carga y procesamiento de imágenes con compresión y filtros automáticos",
                category: .utilities,
                icon: "photo.badge.plus.fill"
            ),
            Module(
                name: "WalletStripe",
                displayName: "Wallet Stripe",
                description: "Integración con Stripe para pagos, billetera digital y transacciones seguras",
                category: .networking,
                icon: "creditcard.fill"
            )
        ]
    }
}