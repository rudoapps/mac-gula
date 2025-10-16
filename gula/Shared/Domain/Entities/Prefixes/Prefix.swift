//
//  Prefix.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 2/9/25.
//

import Foundation

struct Prefix: Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    let prefix: String
    let code: String
    let regex: String
    let minDigits: Int
    let maxDigits: Int

    static func == (lhs: Prefix, rhs: Prefix) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Prefix {
    static let mock = Prefix(id: 1, name: "spain", prefix: "+34", code: "123456789", regex: "regex", minDigits: 1, maxDigits: 3)
}
