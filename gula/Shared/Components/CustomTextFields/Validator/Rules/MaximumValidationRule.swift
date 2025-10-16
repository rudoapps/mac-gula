//
//  MaximumValidationRule.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/9/25.
//

import Foundation

struct MaximumValidationRule: ValidationRule {
    let max: Int

    func validate(_ text: String) -> ValidationResult {
        return text.count > max ?
            .failure(message: ValidationErrorMessage.max.message) :
            .success
    }
}
