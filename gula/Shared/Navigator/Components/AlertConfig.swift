//
//  AlertConfig.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 21/7/25.
//

import SwiftUI

struct AlertConfig {
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    @ViewBuilder let actions: any View

    init(title: LocalizedStringKey, message: LocalizedStringKey, actions: @escaping () -> any View) {
        self.title = title
        self.message = message
        self.actions = actions()
    }
}
