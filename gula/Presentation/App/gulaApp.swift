import SwiftUI
import Sparkle
import GoogleSignIn

@available(macOS 15.0, *)
@main
struct gulaApp: App {
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        // Configurar Google Sign-In
        configureGoogleSignIn()
    }

    private func configureGoogleSignIn() {
        // Intentar leer el CLIENT_ID desde GoogleService-Info.plist
        if let clientID = getGoogleClientID() {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
    }

    private func getGoogleClientID() -> String? {
        // Primero intentar leer desde GoogleService-Info.plist
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let clientID = plist["CLIENT_ID"] as? String,
           !clientID.contains("XXXXXXX") {
            return clientID
        }

        // Si no está en GoogleService-Info, leer desde Info.plist
        if let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String,
           !clientID.contains("TU-OAUTH") {
            return clientID
        }

        // Si no está configurado, usar el de Config.swift
        if Config.googleClientID != "TU-OAUTH-CLIENT-ID.apps.googleusercontent.com" {
            return Config.googleClientID
        }

        return nil
    }
    
    var body: some Scene {
        WindowGroup {
            AuthSwitcherView(root: LoginBuilder().build(isSocialLoginActived: true))
                .onOpenURL { url in
                    // Manejar callbacks de Google Sign-In
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        #endif

        #if os(macOS)
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
        }
        #endif
    }
}

#if os(macOS)
struct CheckForUpdatesView: View {
    let updater: SPUUpdater
    
    var body: some View {
        Button("Check for Updates...") {
            updater.checkForUpdates()
        }
        .disabled(!updater.canCheckForUpdates)
    }
}
#endif
