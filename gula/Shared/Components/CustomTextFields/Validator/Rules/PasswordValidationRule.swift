//
//  PasswordValidationRule.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/9/25.
//

import Foundation

struct PasswordValidationRule: ValidationRule {
    let regex: String

    init(regex: String?) {
        if let regex = regex {
            self.regex = regex
        } else {
            self.regex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*[^a-zA-Z0-9])(?=.*[0-9]).{8,15}$"
        }
    }

    func validate(_ text: String) -> ValidationResult {
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return passwordPredicate.evaluate(with: text) ? .success : .failure(message: ValidationErrorMessage.password.message)
    }
}
