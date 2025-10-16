//
//  PrefixesBuilder.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 5/9/25.
//

import SwiftUI

protocol ChangeSelectedPrefix {
    func changeSelectedPrefix(_ prefix: Prefix)
}

class PrefixesBuilder {
    static func build(
        selectedPrefix: Prefix,
        prefixes: [Prefix],
        delegate: ChangeSelectedPrefix
    ) -> PrefixesView {
        let router = PrefixesRouter()
        let viewModel = PrefixesViewModel(
            router: router,
            prefixes: prefixes,
            selectedPrefix: selectedPrefix,
            delegate: delegate
        )
        return PrefixesView(viewModel: viewModel)
    }
}


