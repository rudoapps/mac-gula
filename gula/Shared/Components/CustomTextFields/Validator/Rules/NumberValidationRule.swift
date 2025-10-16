//
//  NumberValidationRule.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 5/9/25.
//

import Foundation

enum NumberValidationType {
    case fullNumber
    case containsNumber
    case notContainsNumber
}

struct NumberValidationRule: ValidationRule {
    let type: NumberValidationType

    init(type: NumberValidationType) {
        self.type = type
    }

    func validate(_ text: String) -> ValidationResult {
        switch type {
        case .fullNumber:
            return text.allSatisfy({ $0.isNumber }) ?
                .success :
                .failure(message: ValidationErrorMessage.fullNumber.message)
        case .containsNumber:
            return text.contains(where: { $0.isNumber }) ?
                .success :
                .failure(message: ValidationErrorMessage.containsNumber.message)
        case .notContainsNumber:
            return !text.contains(where: { $0.isNumber }) ?
                .success :
                .failure(message: ValidationErrorMessage.containsNumber.message)
        }
    }
}
