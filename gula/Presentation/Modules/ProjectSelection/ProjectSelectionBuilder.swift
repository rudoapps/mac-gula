import Foundation

class ProjectSelectionBuilder {
    static func build(onProjectSelected: @escaping (Project) -> Void) -> ProjectSelectionView {
        let viewModel = ProjectSelectionViewModel()
        viewModel.onProjectSelected = onProjectSelected
        return ProjectSelectionView(viewModel: viewModel)
    }
}