import SwiftUI

@main
struct gulaApp: App {
    @State private var showOnboarding = true
    @State private var selectedProject: Project?
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingBuilder.build {
                    showOnboarding = false
                }
                .frame(minWidth: 900, minHeight: 600)
            } else if selectedProject == nil {
                ProjectSelectionBuilder.build { project in
                    selectedProject = project
                }
                .frame(minWidth: 800, minHeight: 600)
            } else {
                MainContentView(project: selectedProject!)
                    .frame(minWidth: 900, minHeight: 600)
            }
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        #endif
    }
}
