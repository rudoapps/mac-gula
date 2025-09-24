//
//  ConfirmationDialogConfig.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 21/7/25.
//

import SwiftUI

struct ConfirmationDialogConfig {
    @ViewBuilder let actions: any View

    init(actions: @escaping () -> any View) {
        self.actions = actions()
    }
}
