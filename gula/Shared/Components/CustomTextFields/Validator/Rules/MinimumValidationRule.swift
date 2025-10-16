//
//  MinimumValidationRule.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/9/25.
//

import Foundation

struct MinimumValidationRule: ValidationRule {
    let min: Int
    
    func validate(_ text: String) -> ValidationResult {
        return text.count < min ?
            .failure(message: ValidationErrorMessage.min.message) :
            .success
    }
}
