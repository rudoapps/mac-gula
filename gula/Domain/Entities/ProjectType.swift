import Foundation

enum ProjectType: String, CaseIterable, Identifiable, Codable {
    case android = "android"
    case ios = "ios"
    case flutter = "flutter"
    case python = "python"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .android:
            return "Android"
        case .ios:
            return "iOS"
        case .flutter:
            return "Flutter"
        case .python:
            return "Python"
        }
    }
    
    var icon: String {
        switch self {
        case .android:
            return "🤖"
        case .ios:
            return "🍎"
        case .flutter:
            return "🦋"
        case .python:
            return "🐍"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .android:
            return "app.badge"
        case .ios:
            return "apple.logo"
        case .flutter:
            return "paintbrush.pointed"
        case .python:
            return "terminal"
        }
    }
    
    var description: String {
        switch self {
        case .android:
            return "Proyectos nativos Android con Clean Architecture"
        case .ios:
            return "Proyectos nativos iOS con Clean Architecture"
        case .flutter:
            return "Aplicaciones multiplataforma Flutter"
        case .python:
            return "APIs backend con FastAPI o Django"
        }
    }
}