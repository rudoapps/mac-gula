import Foundation

// MARK: - Project Detail Builder

struct ProjectDetailBuilder {
    static func build(project: Project, onBack: @escaping () -> Void, onLogout: @escaping () -> Void) -> ProjectDetailView {
        let viewModel = ProjectDetailViewModel()
        return ProjectDetailView(project: project, onBack: onBack, onLogout: onLogout, viewModel: viewModel)
    }
}