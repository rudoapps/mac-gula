import Foundation

struct SystemDependency: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let installCommand: String
    let checkCommand: String
    let isRequired: Bool
    var isInstalled: Bool = false
    
    static let homebrew = SystemDependency(
        name: "Homebrew",
        description: "El gestor de paquetes para macOS necesario para instalar gula",
        installCommand: "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"",
        checkCommand: "test -f /usr/local/bin/brew || test -f /opt/homebrew/bin/brew",
        isRequired: true
    )
    
    static let gula = SystemDependency(
        name: "Gula CLI",
        description: "La herramienta de línea de comandos de Gula",
        installCommand: "brew tap rudoapps/gula && brew install gula",
        checkCommand: "test -f /usr/local/bin/gula || test -f /opt/homebrew/bin/gula || command -v gula",
        isRequired: true
    )
}

enum DependencyStatus {
    case checking
    case allInstalled
    case missingDependencies([SystemDependency])
    case gulaUpdateRequired(String) // current version
    case updatingGula
    case gulaUpdated
    case error(String)
}