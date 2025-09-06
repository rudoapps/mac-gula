import SwiftUI

@main
struct gulaApp: App {
    @State private var showOnboarding = true
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingBuilder.build {
                    showOnboarding = false
                }
                .frame(minWidth: 900, minHeight: 600)
            } else {
                MainContentView()
                    .frame(minWidth: 900, minHeight: 600)
            }
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        #endif
    }
}
