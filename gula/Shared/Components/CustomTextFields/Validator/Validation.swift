//
//  Validation.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 4/9/25.
//

import Foundation

protocol ValidationRule {
    func validate(_ text: String) -> ValidationResult
}

enum ValidationResult: Equatable {
    case success
    case failure(message: String)
}

enum Validation {
    case min(Int)
    case max(Int)
    case email(regex: String? = nil)
    case password(regex: String? = nil)
    case phone(regex: String)
    case postalCode(regex: String? = nil)
    case isRequired
    case containsNumber
    case fullNumber
    case notContainsNumber
    case matchTexts(matchText: String)

    func rule() -> ValidationRule {
        switch self {
        case .min(let length):
            return MinimumValidationRule(min: length)
        case .max(let length):
            return MaximumValidationRule(max: length)
        case .email(let regex):
            return EmailValidationRule(regex: regex)
        case .password(let regex):
            return PasswordValidationRule(regex: regex)
        case .phone(let regex):
            return PhoneValidationRule(regex: regex)
        case .postalCode(let regex):
            return PostalCodeValidationRule(regex: regex)
        case .isRequired:
            return RequiredValidationRule()
        case .containsNumber:
            return NumberValidationRule(type: .containsNumber)
        case .fullNumber:
            return NumberValidationRule(type: .fullNumber)
        case .notContainsNumber:
            return NumberValidationRule(type: .notContainsNumber)
        case .matchTexts(let matchText):
            return MatchValidationRule(matchText: matchText)
        }
    }
}
