import Foundation

class NewProjectBuilder {
    static func build(onProjectCreated: @escaping (Project) -> Void) -> NewProjectView {
        return NewProjectView(onProjectCreated: onProjectCreated)
    }
}