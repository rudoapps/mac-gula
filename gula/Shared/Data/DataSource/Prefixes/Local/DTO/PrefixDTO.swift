//
//  PrefixesDTO.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 28/8/25.
//

import Foundation

struct PrefixDTO: Codable {
    let id: Int
    let name: String
    let prefix: String
    let code: String
    let regex: String
    let minDigits: Int
    let maxDigits: Int
}
