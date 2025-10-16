//
//  Navigator.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 21/7/25.
//

import SwiftUI

@Observable
class Navigator: NavigatorProtocol {
    // MARK: - Properties
    private(set) var root: Page?
    var path = [Page]()
    var sheet: Page?
    var fullOverSheet: Page?
    var nestedSheet: Page?
    var fullOverNestedSheet: Page?
    var toastConfig: ToastConfig?
    var alertConfig: AlertConfig?
    var tabIndex: Int = 0
    #if canImport(UIKit)
    var tabBadges: [TabItem: Int] = [:]
    #endif
    var fullOverScreenConfig: FullOverScreenConfig?
    var confirmationDialogConfig: ConfirmationDialogConfig?
    var isEnabledBackGesture = true
    var isPresentingAlert = false {
        didSet {
            if isPresentingAlert == false {
                alertConfig = nil
            }
        }
    }
    var isPresentingConfirmationDialog = false {
        didSet {
            if isPresentingConfirmationDialog == false {
                confirmationDialogConfig = nil
            }
        }
    }
    var isPresentingFullOverScreen = false {
        didSet {
            if isPresentingFullOverScreen == false {
                fullOverScreenConfig = nil
                fullOverSheet = nil
                fullOverNestedSheet = nil
            }
        }
    }

    // MARK: - Init
    static var shared = Navigator()

    private init() {
        #if canImport(UIKit)
        TabItem.allCases.forEach { tabBadges[$0] = 0 }
        #endif
    }

    // MARK: - Methods
    func initialize(root view: any View) {
        root = Page(from: view)
    }
}

// MARK: - Functions NavigatorManagerProtocol 
extension Navigator {
    func push(to view: any View) {
        path.append(Page(from: view))
    }

    func pushAndRemovePrevious(to view: any View) {
        path.append(Page(from: view))
        path.remove(at: path.count - 2)
    }

    func dismiss() {
        path.removeLast()
    }

    func dismissSheet() {
        if isPresentingFullOverScreen {
            if fullOverNestedSheet != nil {
                fullOverNestedSheet = nil
            } else {
                fullOverSheet = nil
            }
        } else {
            if nestedSheet != nil {
                nestedSheet = nil
            } else {
                sheet = nil
            }
        }
    }

    func dismissFullOverScreen() {
        isPresentingFullOverScreen = false
    }

    func dismissAll() {
        path.removeAll()
    }

    func replaceRoot(to view: any View) {
        root = Page(from: view)
        path.removeAll()
        sheet = nil
        nestedSheet = nil
        fullOverSheet = nil
        fullOverNestedSheet = nil
    }

    func present(view: any View) {
        if isPresentingFullOverScreen {
            if fullOverSheet != nil {
                fullOverNestedSheet = Page(from: view)
            } else {
                fullOverSheet = Page(from: view)
            }
        } else {
            if sheet != nil {
                nestedSheet = Page(from: view)
            } else {
                sheet = Page(from: view)
            }
        }
    }

    func presentCustomConfirmationDialog(from config: ConfirmationDialogConfig) {
        confirmationDialogConfig = config
        isPresentingConfirmationDialog = true
    }

    func changeTab(index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tabIndex = index
        }
    }
}

// MARK: - Functions ModalPresentProtocol
extension Navigator {
    func showAlert(from config: AlertConfig) {
        alertConfig = config
        isPresentingAlert = true
    }

    func showToast(from toast: ToastConfig) {
        if toastConfig != nil {
            dismissToast()
        }
        toastConfig = toast
    }

    func dismissToast() {
        toastConfig = nil
    }

    func showErrorAlert(title: String, message: String, action: @escaping () -> Void) {
        alertConfig =  AlertConfig(
            title: LocalizedStringKey(title),
            message: LocalizedStringKey(message),
            actions: {
                Button("common_accept", role: .cancel) { action() }
            })
        isPresentingAlert = true
    }

    func showErrorAlert(_ error: Error, action: @escaping () -> Void) {
        let errorToShow = (error as? (any DetailErrorProtocol)) ?? AppError.generalError

        alertConfig = AlertConfig(
            title: LocalizedStringKey(errorToShow.title),
            message: LocalizedStringKey(errorToShow.message),
            actions: {
                Button("common_accept", role: .cancel) { action() }
            }
        )

        isPresentingAlert = true
    }

    func showAlertPermission(title: String, message: String, action: @escaping () -> Void) {
        alertConfig =  AlertConfig(
            title: LocalizedStringKey(title),
            message: LocalizedStringKey(message),
            actions: {
                VStack {
                    Button("common_cancel", role: .cancel) {}
                    Button("common_goToSettings") {
                        #if canImport(UIKit)
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings)
                        }
                        #else
                        // macOS: Open System Settings
                        if let url = URL(string: "x-apple.systempreferences:") {
                            NSWorkspace.shared.open(url)
                        }
                        #endif
                        action()
                    }
                }
            })
        isPresentingAlert = true
    }

    func presentFullOverScreen(view: any View) {
        fullOverScreenConfig = FullOverScreenConfig(view: view)
        isPresentingFullOverScreen =  true
    }
}
