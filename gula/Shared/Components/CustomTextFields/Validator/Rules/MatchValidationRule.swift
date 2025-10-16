//
//  MatchValidationRule.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 8/9/25.
//

import Foundation

struct MatchValidationRule: ValidationRule {
    let matchText: String

    func validate(_ text: String) -> ValidationResult {
        text == matchText ? .success : .failure(message: "common_error_fields_not_match")
    }
}
