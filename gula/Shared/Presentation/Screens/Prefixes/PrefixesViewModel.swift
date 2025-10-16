//
//  PrefixesViewModel.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 5/9/25.
//

import Foundation

class PrefixesViewModel: ObservableObject {
    private let router: PrefixesRouter
    private let delegate: ChangeSelectedPrefix?

    let prefixes: [Prefix]
    @Published var selectedPrefix: Prefix

    init(
        router: PrefixesRouter,
        prefixes: [Prefix],
        selectedPrefix: Prefix,
        delegate: ChangeSelectedPrefix
    ) {
        self.router = router
        self.prefixes = prefixes
        self.selectedPrefix = selectedPrefix
        self.delegate = delegate
    }

    func changeSelectedPrefix(_ prefix: Prefix) {
        selectedPrefix = prefix
        delegate?.changeSelectedPrefix(prefix)
        router.dismissSheet()
    }
}
