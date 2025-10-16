//
//  Validator.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/9/25.
//

import Foundation

struct Validator {
    private let rules: [ValidationRule]

    init(validations: [Validation]) {
        self.rules = validations.map{ $0.rule() }
    }

    func validate(_ text: String) -> ValidationResult {
        for rule in rules {
            let result = rule.validate(text)
            if case .failure = result {
                return result
            }
        }
        return .success
    }
}
