//
//  ToastConfig.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 31/7/25.
//

import SwiftUI

struct ToastConfig {
    @ViewBuilder let view: any View

    init(view: any View) {
        self.view = view
    }
}
