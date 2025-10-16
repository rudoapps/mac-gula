//
//  RequiredValidationRule.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/9/25.
//

import Foundation

struct RequiredValidationRule: ValidationRule {
    func validate(_ text: String) -> ValidationResult {
        text.isEmpty ? .failure(message: ValidationErrorMessage.isRequired.message) : .success
    }
}
