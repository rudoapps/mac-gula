//
//  PrefixesUseCase.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 2/9/25.
//

import Foundation

struct PrefixesUseCase: PrefixesUseCaseProtocol {
    private let repository: PrefixesRepositoryProtocol

    init(repository: PrefixesRepositoryProtocol) {
        self.repository = repository
    }

    func getPrefixes() -> [Prefix] {
        repository.getPrefixes()
    }
}
