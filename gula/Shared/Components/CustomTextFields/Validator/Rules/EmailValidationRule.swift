//
//  EmailValidationRule.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 5/9/25.
//

import Foundation

struct EmailValidationRule: ValidationRule {
    let regex: String

    init(regex: String?) {
        if let regex = regex {
            self.regex = regex
        } else {
            self.regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,})$"
        }
    }

    func validate(_ text: String) -> ValidationResult {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return emailPredicate.evaluate(with: text) ? .success : .failure(message: ValidationErrorMessage.email.message)
    }
}
