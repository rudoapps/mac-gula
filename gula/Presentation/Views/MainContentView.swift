import SwiftUI

@available(macOS 15.0, *)
struct MainContentView: View {
    let project: Project
    let onBack: () -> Void
    let onLogout: () -> Void

    var body: some View {
        ProjectDetailView(
            project: project,
            onBack: onBack,
            onLogout: onLogout
        )
        .background(
            Button("") {
                onBack()
            }
            .keyboardShortcut(.escape, modifiers: [])
            .hidden()
        )
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProject = Project(
            name: "Sample Project",
            path: "/Users/sample/project",
            type: .flutter
        )
        return MainContentView(
            project: sampleProject,
            onBack: { print("Back button pressed") },
            onLogout: { print("Logout pressed") }
        )
    }
}