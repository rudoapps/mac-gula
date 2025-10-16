//
//  PhoneValidationRule.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/9/25.
//

import Foundation

struct PhoneValidationRule: ValidationRule {
    let regex: String

    func validate(_ text: String) -> ValidationResult {
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return phonePredicate.evaluate(with: text) ? .success : .failure(message: ValidationErrorMessage.phone.message)
    }
}
