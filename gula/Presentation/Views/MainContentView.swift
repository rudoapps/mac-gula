import SwiftUI

struct MainContentView: View {
    let project: Project
    let onBack: () -> Void
    
    var body: some View {
        ProjectDetailView(
            project: project,
            onBack: onBack
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

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProject = Project(
            name: "Sample Project",
            path: "/Users/sample/project",
            type: .flutter
        )
        return MainContentView(project: sampleProject) {
            print("Back button pressed")
        }
    }
}