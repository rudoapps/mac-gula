import Foundation

class NewProjectBuilder {
    @available(macOS 15.0, *)
    static func build(onProjectCreated: @escaping (Project) -> Void) -> NewProjectView {
        return NewProjectView(onProjectCreated: onProjectCreated)
    }
}
