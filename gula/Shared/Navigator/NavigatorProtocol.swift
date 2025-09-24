//
//  NavigatorProtocol.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 21/7/25.
//

import SwiftUI

protocol NavigatorProtocol: NavigatorManagerProtocol, ModalPresenterProtocol {
    // MARK: - Properties
    var path: [Page] { get set }
    var root: Page? { get }
    // MARK: - Methods
    func initialize(root view: any View)
}

protocol NavigatorManagerProtocol {
    // MARK: - Properties
    var sheet: Page? { get set }
    var fullOverSheet: Page? { get set }
    var nestedSheet: Page? { get set }
    var fullOverNestedSheet: Page? { get set }
    var isEnabledBackGesture: Bool { get set }

    // MARK: - Methods
    func push(to view: any View)
    func pushAndRemovePrevious(to view: any View)
    func dismiss()
    func dismissSheet()
    func dismissFullOverScreen()
    func dismissAll()
    func replaceRoot(to view: any View)
    func present(view: any View)
    func presentCustomConfirmationDialog(from config: ConfirmationDialogConfig)
}


protocol ModalPresenterProtocol {
    // MARK: - Properties
    var toastConfig: ToastConfig? { get set }
    var alertConfig: AlertConfig? { get }
    var confirmationDialogConfig: ConfirmationDialogConfig? { get }
    var fullOverScreenConfig: FullOverScreenConfig? { get }
    var isPresentingAlert: Bool { get set }
    var isPresentingConfirmationDialog: Bool { get set }
    var isPresentingFullOverScreen: Bool { get set }

    // MARK: - Methods
    func showAlert(from config: AlertConfig)
    func showToast(from toast: ToastConfig)
    func showErrorAlert(title: String, message: String, action: @escaping () -> Void)
    func showErrorAlert(_ error: Error, action: @escaping () -> Void) 
    func showAlertPermission(title: String, message: String, action: @escaping () -> Void)
    func presentFullOverScreen(view: any View)
    func dismissToast()
}

