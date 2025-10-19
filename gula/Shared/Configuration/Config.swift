//
//  Configuration.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 16/7/24.
//

import Foundation

@available(macOS 15.0, *)
class Config: ConfigTripleA {
    static var shared = Config()

    static let baseURL = "https://services.rudo.es/"
    static let clientID = ""
    static let clientSecret = ""
    static let scheme = "gula"
    static let appName = "Gula"
    static let chatApiAccessToken = "VY2XjB6euy4wRW2hdvlok7PFWg1BlLVb"
    static let chatApiSignatureMatch = "12155909626"

    // Google Sign-In OAuth Client ID
    // Se lee automáticamente desde GoogleService-Info.plist
    static let googleClientID = "946402254847-unc3g796c05qau1u349f2k5iokiaufk9.apps.googleusercontent.com"
}
