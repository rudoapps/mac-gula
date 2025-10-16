//
//  LocalPrefixesDataSourceProtocol.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 28/8/25.
//

import Foundation

protocol LocalPrefixesDataSourceProtocol {
    func getPrefixes() -> [PrefixDTO]
}
