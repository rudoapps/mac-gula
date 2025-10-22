import Foundation

@available(macOS 15.0, *)
class ProjectSelectionBuilder {
    static func build(onProjectSelected: @escaping (Project) -> Void) -> ProjectSelectionView {
        let viewModel = ProjectSelectionViewModel()
        viewModel.onProjectSelected = onProjectSelected
        return ProjectSelectionView(viewModel: viewModel)
    }
}
