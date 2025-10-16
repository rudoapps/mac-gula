//
//  PrefixesRepository.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 28/8/25.
//

import Foundation

class PrefixesRepository: PrefixesRepositoryProtocol {
    private let localDataSource: LocalPrefixesDataSourceProtocol

    init(localDataSource: LocalPrefixesDataSourceProtocol) {
        self.localDataSource = localDataSource
    }

    func getPrefixes() -> [Prefix] {
        let prefixesDTO = localDataSource.getPrefixes()
        return prefixesDTO.map { $0.toDomain() }
    }
}

// MARK: - Mappers
fileprivate extension PrefixDTO {
    func toDomain() -> Prefix {
        Prefix(
            id: self.id,
            name: self.name,
            prefix: self.prefix,
            code: self.code,
            regex: self.regex,
            minDigits: self.minDigits,
            maxDigits: self.maxDigits
        )
    }
}
