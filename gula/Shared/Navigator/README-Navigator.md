# Documentation

https://slash-toque-35b.notion.site/Navegaci-n-Swift-UI-17424295dc278087b66dea2dbce74c87

## In your project create - ContentView

- Example in app file

```swift
@main
struct NameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(root: Login.build())
        }
    }
}
```

- Example with authentication module

```swift
import SwiftUI

struct ContentView: View {
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
            case .login, .home:
                navigator.replaceRoot(to: MainMenuBuilder.build())
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
        .fullScreenCover(isPresented: $navigator.isPresentingFullOverScreen) {
            if let fullOverScreenConfig = navigator.fullOverScreenConfig {
                NestedFullScreenHost(navigator: navigator) {
                    AnyView(fullOverScreenConfig.view)
                }
            }
        }
    }
}
```
- Example without authentication module

```swift
import SwiftUI

struct ContentView: View {
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
        .confirmationDialog("",
                            isPresented: $navigator.isPresentingConfirmationDialog,
                            titleVisibility: .hidden) {
            if let confirmationDialogConfig = navigator.confirmationDialogConfig {
                AnyView(confirmationDialogConfig.actions)
            }
        }
        .fullScreenCover(isPresented: $navigator.isPresentingFullOverScreen) {
            if let fullOverScreenConfig = navigator.fullOverScreenConfig {
                NestedFullScreenHost(navigator: navigator) {
                    AnyView(fullOverScreenConfig.view)
                }
            }
        }
    }
}
```

- Example of Tabbar usage

- Step 1: 
   To show customTabBar you just need to pass de initialTab that you want to us to navigate
    ```    
     Example:
        navigator.replaceRoot(to: CustomTabbar(initialTab: .login))
    ```

- Step 2:
    In case you have a navigation flow that end up dismissing the tabbar and you need to navigate to another tab. You need to declare this on the router:
    ``` 
       navigator.changeTab(index: TabItem.images.rawValue)
    ```
    
- Example for changing Tab badges from any View
    ``` 
        navigator.tabBadges[.documents] = 3
        
    ```
- Example for changing the TabBar configuration 
        Just add your own colors and design
    ``` 
       let newConfig = TabBarConfig(
        backgroundColor: .black,
        badgeColor: .red,
        badgeTextColor: .white,
        selectedTabColor: .orange,
        textTabColor: .white
    )

        CustomTabBar.config = newConfig
    ```
