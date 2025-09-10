import Foundation

struct Project: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let type: ProjectType
    let lastOpened: Date
    
    init(name: String, path: String, type: ProjectType, lastOpened: Date = Date()) {
        self.name = name
        self.path = path
        self.type = type
        self.lastOpened = lastOpened
    }
    
    var displayPath: String {
        return path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }
    
    var relativeLastOpened: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.localizedString(for: lastOpened, relativeTo: Date())
    }
    
    var exists: Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}

// MARK: - Project Detection
extension Project {
    static func detectProjectType(at path: String) -> ProjectType? {
        let fileManager = FileManager.default
        
        // Check for Android project
        if fileManager.fileExists(atPath: "\(path)/app/build.gradle") ||
           fileManager.fileExists(atPath: "\(path)/app/build.gradle.kts") {
            return .android
        }
        
        // Check for iOS project - look for any .xcodeproj or .xcworkspace
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            for item in contents {
                if item.hasSuffix(".xcodeproj") || item.hasSuffix(".xcworkspace") {
                    return .ios
                }
            }
        } catch {
            // If we can't read directory contents, try the old method as fallback
            let pathURL = URL(fileURLWithPath: path)
            let projectName = pathURL.lastPathComponent
            if fileManager.fileExists(atPath: "\(path)/\(projectName).xcodeproj") ||
               fileManager.fileExists(atPath: "\(path)/\(projectName).xcworkspace") ||
               path.hasSuffix(".xcodeproj") || path.hasSuffix(".xcworkspace") {
                return .ios
            }
        }
        
        // Check for Flutter project
        if fileManager.fileExists(atPath: "\(path)/pubspec.yaml") {
            return .flutter
        }
        
        // Check for Python project
        if fileManager.fileExists(atPath: "\(path)/requirements.txt") ||
           fileManager.fileExists(atPath: "\(path)/pyproject.toml") ||
           fileManager.fileExists(atPath: "\(path)/setup.py") ||
           fileManager.fileExists(atPath: "\(path)/Pipfile") {
            return .python
        }
        
        return nil
    }
    
    static func createFromPath(_ path: String) -> Project? {
        guard let type = detectProjectType(at: path) else { return nil }
        
        let projectName = URL(fileURLWithPath: path).lastPathComponent
        return Project(name: projectName, path: path, type: type)
    }
}