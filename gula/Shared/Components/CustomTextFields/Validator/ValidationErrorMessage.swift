//
//  ValidationMessage.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 6/9/25.
//

import Foundation

enum ValidationErrorMessage {
    case min
    case max
    case email
    case password
    case phone
    case postalCode
    case isRequired
    case containsNumber
    case fullNumber
    case wrongFormat

    var message: String {
        switch self {
        case .min:
            return "common_min_length"
        case .max:
            return "common_max_length"
        case .email:
            return "common_invalid_email"
        case .password:
            return "common_invalid_password"
        case .phone:
            return "common_invalid_phone"
        case .postalCode:
            return "common_invalid_postal_code"
        case .isRequired:
            return "common_required_field"
        case .containsNumber:
            return "common_must_contain_number"
        case .fullNumber:
            return "common_must_be_number"
        case .wrongFormat:
            return "common_wrong_format"
        }
    }
}
