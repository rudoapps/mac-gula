import Foundation

// MARK: - Pre-commit Hook Models

struct PreCommitHook: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let repo: String
    let rev: String
    let hookId: String
    let args: [String]
    let supportedProjectTypes: [ProjectType]
    let category: PreCommitCategory
    let isEnabled: Bool
    let configurationRequired: Bool
    let icon: String
    
    init(
        id: String,
        name: String,
        description: String,
        repo: String,
        rev: String,
        hookId: String,
        args: [String] = [],
        supportedProjectTypes: [ProjectType],
        category: PreCommitCategory,
        isEnabled: Bool = false,
        configurationRequired: Bool = false,
        icon: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.repo = repo
        self.rev = rev
        self.hookId = hookId
        self.args = args
        self.supportedProjectTypes = supportedProjectTypes
        self.category = category
        self.isEnabled = isEnabled
        self.configurationRequired = configurationRequired
        self.icon = icon
    }
}

enum PreCommitCategory: String, CaseIterable, Codable {
    case linting = "Linting"
    case formatting = "Formatting"
    case testing = "Testing"
    case security = "Security"
    case build = "Build"
    case custom = "Custom"
    
    var color: String {
        switch self {
        case .linting: return "blue"
        case .formatting: return "green"
        case .testing: return "orange"
        case .security: return "red"
        case .build: return "purple"
        case .custom: return "gray"
        }
    }
    
    var icon: String {
        switch self {
        case .linting: return "checkmark.shield"
        case .formatting: return "textformat"
        case .testing: return "testtube.2"
        case .security: return "lock.shield"
        case .build: return "hammer"
        case .custom: return "gear"
        }
    }
}

struct HookStatus: Identifiable, Codable {
    let id = UUID()
    let hookName: String
    let isInstalled: Bool
    let isWorking: Bool
    let lastRun: Date?
    let lastRunDuration: TimeInterval?
    let lastError: String?
    
    var statusText: String {
        if !isInstalled {
            return "Not installed"
        } else if !isWorking {
            return "Error: \(lastError ?? "Unknown")"
        } else {
            return "Working"
        }
    }
    
    var statusColor: String {
        if !isInstalled {
            return "gray"
        } else if !isWorking {
            return "red"
        } else {
            return "green"
        }
    }
}

struct PreCommitConfig: Codable {
    let repos: [PreCommitRepo]
    let defaultInstallHookTypes: [String]?
    let defaultStages: [String]?
    
    init(repos: [PreCommitRepo], defaultInstallHookTypes: [String]? = nil, defaultStages: [String]? = nil) {
        self.repos = repos
        self.defaultInstallHookTypes = defaultInstallHookTypes
        self.defaultStages = defaultStages
    }
}

struct PreCommitProjectStatus {
    let toolInstalled: Bool           // pre-commit tool installed globally
    let configExists: Bool            // .pre-commit-config.yaml exists
    let hooksInstalled: Bool          // hooks installed in .git/hooks/
    let configuredHooks: [String]     // hooks listed in config file
    
    var isFullyConfigured: Bool {
        return toolInstalled && configExists && hooksInstalled
    }
    
    var statusMessage: String {
        if !toolInstalled {
            return "Pre-commit tool no está instalado globalmente"
        } else if !configExists {
            return "No hay configuración en este proyecto"
        } else if !hooksInstalled {
            return "Configuración existe pero hooks no están instalados"
        } else {
            return "Pre-commit está completamente configurado"
        }
    }
    
    var statusLevel: PreCommitStatusLevel {
        if isFullyConfigured {
            return .configured
        } else if configExists {
            return .partiallyConfigured
        } else {
            return .notConfigured
        }
    }
}

enum PreCommitStatusLevel {
    case configured
    case partiallyConfigured  
    case notConfigured
}

struct PreCommitRepo: Codable {
    let repo: String
    let rev: String
    let hooks: [PreCommitHookConfig]
}

struct PreCommitHookConfig: Codable {
    let id: String
    let name: String?
    let entry: String?
    let language: String?
    let args: [String]?
    let files: String?
    let excludeFiles: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case entry
        case language
        case args
        case files
        case excludeFiles = "exclude"
    }
}

enum PreCommitError: LocalizedError {
    case notGitRepository
    case preCommitNotInstalled
    case configurationInvalid
    case hookInstallationFailed(String)
    case hookExecutionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notGitRepository:
            return "This project is not a Git repository"
        case .preCommitNotInstalled:
            return "Pre-commit tool is not installed"
        case .configurationInvalid:
            return "Pre-commit configuration is invalid"
        case .hookInstallationFailed(let hook):
            return "Failed to install hook: \(hook)"
        case .hookExecutionFailed(let hook):
            return "Hook execution failed: \(hook)"
        }
    }
}

// MARK: - Predefined Hooks

extension PreCommitHook {
    static let iOSHooks: [PreCommitHook] = [
        PreCommitHook(
            id: "swiftlint",
            name: "SwiftLint",
            description: "A tool to enforce Swift style and conventions",
            repo: "https://github.com/realm/SwiftLint",
            rev: "0.50.3",
            hookId: "swiftlint",
            args: ["--strict"],
            supportedProjectTypes: [.ios],
            category: .linting,
            configurationRequired: true,
            icon: "swift"
        ),
        PreCommitHook(
            id: "swiftformat",
            name: "SwiftFormat",
            description: "A code library and command-line formatting tool for reformatting Swift code",
            repo: "https://github.com/nicklockwood/SwiftFormat",
            rev: "0.52.7",
            hookId: "swiftformat",
            supportedProjectTypes: [.ios],
            category: .formatting,
            icon: "textformat"
        ),
        PreCommitHook(
            id: "ios-build-check",
            name: "iOS Build Check",
            description: "Verify that iOS project builds successfully",
            repo: "local",
            rev: "",
            hookId: "ios-build-check",
            args: ["--", "xcodebuild", "-scheme", "YourScheme", "build"],
            supportedProjectTypes: [.ios],
            category: .build,
            configurationRequired: true,
            icon: "hammer"
        )
    ]
    
    static let androidHooks: [PreCommitHook] = [
        PreCommitHook(
            id: "ktlint",
            name: "ktlint",
            description: "An anti-bikeshedding Kotlin linter with built-in formatter",
            repo: "https://github.com/pinterest/ktlint",
            rev: "0.48.2",
            hookId: "ktlint",
            args: ["--android", "--color"],
            supportedProjectTypes: [.android],
            category: .linting,
            icon: "checkmark.shield"
        ),
        PreCommitHook(
            id: "detekt",
            name: "Detekt",
            description: "A static code analysis tool for the Kotlin programming language",
            repo: "https://github.com/detekt/detekt",
            rev: "v1.22.0",
            hookId: "detekt",
            supportedProjectTypes: [.android],
            category: .linting,
            icon: "magnifyingglass"
        ),
        PreCommitHook(
            id: "android-lint",
            name: "Android Lint",
            description: "Run Android lint checks",
            repo: "local",
            rev: "",
            hookId: "android-lint",
            supportedProjectTypes: [.android],
            category: .linting,
            icon: "checkmark.shield"
        )
    ]
    
    static let flutterHooks: [PreCommitHook] = [
        PreCommitHook(
            id: "dart-analyze",
            name: "Dart Analyze",
            description: "Analyze Dart code for potential issues",
            repo: "local",
            rev: "",
            hookId: "dart-analyze",
            supportedProjectTypes: [.flutter],
            category: .linting,
            icon: "magnifyingglass.circle"
        ),
        PreCommitHook(
            id: "dart-format",
            name: "Dart Format",
            description: "Format Dart code according to Dart style guidelines",
            repo: "local",
            rev: "",
            hookId: "dart-format",
            supportedProjectTypes: [.flutter],
            category: .formatting,
            icon: "textformat.size"
        ),
        PreCommitHook(
            id: "flutter-test",
            name: "Flutter Test",
            description: "Run Flutter unit tests",
            repo: "local",
            rev: "",
            hookId: "flutter-test",
            supportedProjectTypes: [.flutter],
            category: .testing,
            icon: "testtube.2"
        )
    ]
    
    static let pythonHooks: [PreCommitHook] = [
        PreCommitHook(
            id: "black",
            name: "Black",
            description: "The uncompromising Python code formatter",
            repo: "https://github.com/psf/black",
            rev: "22.10.0",
            hookId: "black",
            supportedProjectTypes: [.python],
            category: .formatting,
            icon: "textformat"
        ),
        PreCommitHook(
            id: "flake8",
            name: "Flake8",
            description: "Python linting tool for style guide enforcement",
            repo: "https://github.com/pycqa/flake8",
            rev: "5.0.4",
            hookId: "flake8",
            supportedProjectTypes: [.python],
            category: .linting,
            icon: "checkmark.shield"
        ),
        PreCommitHook(
            id: "mypy",
            name: "MyPy",
            description: "Static type checker for Python",
            repo: "https://github.com/pre-commit/mirrors-mypy",
            rev: "v0.991",
            hookId: "mypy",
            supportedProjectTypes: [.python],
            category: .linting,
            icon: "checkmark.shield.fill"
        )
    ]
    
    static func availableHooks(for projectType: ProjectType) -> [PreCommitHook] {
        switch projectType {
        case .ios:
            return iOSHooks
        case .android:
            return androidHooks
        case .flutter:
            return flutterHooks
        case .python:
            return pythonHooks
        }
    }
    
    static let allHooks = iOSHooks + androidHooks + flutterHooks + pythonHooks
}