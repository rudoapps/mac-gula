//
//  PostalCodeValidationRule.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/9/25.
//


import Foundation

struct PostalCodeValidationRule: ValidationRule {
    let regex: String

    init(regex: String?) {
        if let regex = regex {
            self.regex = regex
        } else {
            self.regex = "^[0-5][0-9]$"
        }
    }

    func validate(_ text: String) -> ValidationResult {
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return phonePredicate.evaluate(with: text) ? .success : .failure(message: ValidationErrorMessage.postalCode.message)
    }
}
