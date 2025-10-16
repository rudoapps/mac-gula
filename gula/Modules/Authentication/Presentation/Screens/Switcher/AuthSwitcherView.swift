import SwiftUI

@available(macOS 15.0, *)
struct AuthSwitcherView: View {
    @StateObject var authenticator = Config.shared.authenticator
    @State var navigator: NavigatorProtocol
    let rootTransition: AnyTransition = .opacity
    private var deeplinkManager: DeepLinkManagerProtocol

    init(navigator: NavigatorProtocol = Navigator.shared,
         root: any View,
         deeplinkManager: DeepLinkManagerProtocol = DeepLinkManager.shared) {
        self.navigator = navigator
        self.deeplinkManager = deeplinkManager
        navigator.initialize(root: root)
    }

    var body: some View {
        NavigationStack(path: $navigator.path) {
            ZStack {
                if let root = navigator.root {
                    root.transition(rootTransition)
                }
            }
            .navigationDestination(for: Page.self) { page in
                page
            }
        }
        .animation(.default, value: navigator.root)
        .sheet(item: $navigator.sheet) { page in
            NestedSheetHost(navigator: navigator, content: page)
        }
        .alert(navigator.alertConfig?.title ?? "",
               isPresented: $navigator.isPresentingAlert) {
            if let alertConfig = navigator.alertConfig {
                AnyView(alertConfig.actions)
            }
        } message: {
            Text(navigator.alertConfig?.message ?? "")
        }
        .onOpenURL { incomingURL in
            deeplinkManager.manage(this: incomingURL)
        }
        .overlay(
            VStack {
                Spacer()
                if let toastConfig = navigator.toastConfig {
                    AnyView(toastConfig.view)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                withAnimation { navigator.toastConfig = nil }
                            }
                        }
                        .padding(.bottom, 8)
                }
            }
            .ignoresSafeArea(.keyboard)
        )
        .onChange(of: authenticator.screen) {
            switch authenticator.screen {
            case .login:
                navigator.replaceRoot(to: LoginBuilder().build(isSocialLoginActived: false))
            case .home:
                navigator.replaceRoot(to: AppFlowView())
            case .loading:
                navigator.replaceRoot(to: ProgressView())
            }
        }
        .confirmationDialog("",
                            isPresented: $navigator.isPresentingConfirmationDialog,
                            titleVisibility: .hidden) {
            if let confirmationDialogConfig = navigator.confirmationDialogConfig {
                AnyView(confirmationDialogConfig.actions)
            }
        }
    }
}
