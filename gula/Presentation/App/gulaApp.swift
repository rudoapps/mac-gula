import SwiftUI

@main
struct gulaApp: App {
    
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .frame(minWidth: 900, minHeight: 600)
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        #endif
    }
}
