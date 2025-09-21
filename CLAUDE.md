# CLAUDE.md - Contexto del Proyecto Gula

## 📖 Resumen del Proyecto

**Gula** es una aplicación nativa de macOS desarrollada en SwiftUI que funciona como herramienta de desarrollo para gestión de proyectos y automatización de tareas. Es una app comercial con actualizaciones automáticas via Sparkle.

### Propósito Principal
- Gestión y organización de proyectos de desarrollo
- Generación automática de código y módulos
- Integración con herramientas de desarrollo (Git, pre-commit hooks)
- Automatización de tareas repetitivas de desarrollo

## 🏗️ Arquitectura del Proyecto

### Estructura Clean Architecture (Domain-Data-Presentation)
```
gula/
├── Domain/           # Entidades, casos de uso, repositorios (interfaces)
│   ├── Entities/     # Modelos de dominio
│   ├── Repositories/ # Interfaces de repositorios
│   └── Usecases/     # Lógica de negocio
├── Data/             # Implementaciones de repositorios y fuentes de datos
│   ├── Datasources/  # Fuentes de datos
│   └── Repositories/ # Implementaciones concretas
├── Presentation/     # UI, ViewModels, Services
│   ├── App/          # Configuración de la app
│   ├── Modules/      # Módulos funcionales (Home, ProjectDetail, etc.)
│   ├── Views/        # Vistas compartidas
│   └── Services/     # Servicios de presentación
└── Resources/        # Assets, localizaciones, etc.
```

### Tecnologías Principales
- **SwiftUI**: Framework UI principal
- **Combine**: Programación reactiva
- **Sparkle**: Sistema de actualizaciones automáticas
- **Clean Architecture**: Patrón arquitectónico

## 🎯 Funcionalidades Clave

### Módulos Principales
1. **Home**: Vista principal con gestión de proyectos
2. **ProjectDetail**: Detalle y gestión individual de proyectos
3. **APIGenerator**: Generación de código desde OpenAPI
4. **TemplateGenerator**: Sistema de templates personalizables

### Servicios Críticos
- **ProjectManager**: Gestión central de proyectos
- **GitAnalyticsService**: Análisis de repositorios Git
- **MCPService**: Integración con servicios externos
- **SystemRepository**: Gestión de dependencias del sistema

## 📋 Estado Actual del Proyecto

### Últimos Cambios (según git log)
- ✅ Sistema de releases automáticos configurado
- ✅ Integración con Sparkle para actualizaciones
- ✅ Generador de APIs desde OpenAPI
- ✅ Mejoras en ProjectManager y UI

### Archivos Modificados Recientemente
- `.claude/settings.local.json`: Configuración de permisos
- `.gitignore`: Exclusiones de Git actualizadas
- `gula/Resources/Localizable/Localizable.xcstrings`: Localizaciones

### Archivos Pendientes de Commit
- `README_PUBLIC.md`: README público
- `RELEASE.md`: Guía de releases
- `releases-repo/`: Repositorio de releases

## 🔧 Patrones y Convenciones de Desarrollo

### Estilo de Código
- **SwiftUI**: Declarativo, uso de ViewModels para lógica
- **Naming**: PascalCase para clases, camelCase para propiedades
- **Organización**: Un archivo por componente/vista
- **Arquitectura**: Separación clara entre capas (Domain/Data/Presentation)

### Patrones de Desarrollo
- **MVVM**: Para vistas complejas con ViewModels
- **Repository Pattern**: Abstracción de fuentes de datos
- **Dependency Injection**: Via inicializadores
- **Combine**: Para programación reactiva y binding

### Convenciones de Módulos
- Cada módulo contiene: View, ViewModel (si necesario), Types
- Nomenclatura: `[ModuleName]View.swift`, `[ModuleName]ViewModel.swift`
- Organización por funcionalidad, no por tipo de archivo

## 🚀 Proceso de Desarrollo

### Comandos de Build y Test
```bash
# Build del proyecto
xcodebuild -project gula.xcodeproj -scheme gula build

# Build con timeout para CI
timeout 180 xcodebuild -project gula.xcodeproj -scheme gula build

# Verificación de sintaxis Swift
/usr/bin/xcrun --sdk macosx swiftc -c [archivo.swift] -I gula/
```

### Release Process
- Automated via GitHub Actions
- Sparkle integration for auto-updates
- DMG generation and signing
- Version management in Xcode project

## 📦 Dependencias y Herramientas

### Dependencias Principales
- **Sparkle**: Actualizaciones automáticas
- **SwiftUI**: Framework UI
- **Foundation**: APIs base de Swift

### Herramientas de Desarrollo
- **Xcode**: IDE principal
- **GitHub Actions**: CI/CD
- **create-dmg**: Creación de instaladores
- **pre-commit**: Hooks de validación

## 🎯 Tareas y Prioridades

### ✅ Completadas Recientemente
- Sistema de releases automáticos
- Integración Sparkle
- Generador de APIs OpenAPI
- Mejoras en gestión de proyectos

### 🔄 En Progreso
- Documentación del proyecto (este archivo)
- Mejoras en la UI de gestión de proyectos

### 📋 Pendientes
- Tests unitarios para casos de uso críticos
- Mejoras en el sistema de templates
- Optimización de performance en listas grandes
- Documentación de APIs internas

## 🔐 Configuración y Secretos

### Archivos de Configuración
- `.claude/settings.local.json`: Permisos de Claude Code
- `ExportOptions.plist`: Opciones de exportación Xcode
- `appcast.xml`: Feed de actualizaciones Sparkle

### Secretos (NO incluir valores reales)
- `SPARKLE_PRIVATE_KEY`: Clave privada para firmar updates
- `sparkle_public_key.pem`: Clave pública en el repositorio

## 📝 Notas para Futuras Sesiones

### Contexto Importante
- Este es un proyecto comercial activo con usuarios reales
- Las actualizaciones se distribuyen automáticamente via Sparkle
- Mantener compatibilidad con macOS 15.0+
- Priorizar estabilidad sobre nuevas features

### Decisiones Técnicas Clave
- **Clean Architecture**: Elegida para escalabilidad y testing
- **SwiftUI puro**: Sin UIKit para mantener modernidad
- **Combine**: Para reactive programming y data binding
- **Modular**: Cada feature como módulo independiente

### Áreas de Mejora Identificadas
- Cobertura de tests (actualmente limitada)
- Performance en listas con muchos elementos
- Documentación de APIs internas
- Mejoras en UX para usuarios novatos

---

**Última actualización**: 2025-09-19
**Versión del proyecto**: 1.0.0 (en desarrollo activo)
**Claude Code Session**: Archivo creado para mantener coherencia entre sesiones