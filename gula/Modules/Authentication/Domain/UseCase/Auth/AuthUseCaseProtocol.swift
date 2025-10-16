//
//  AuthUseCaseProtocol.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 8/7/24.
//

import Foundation

protocol AuthUseCaseProtocol {
    func login(with email: String, and password: String) async throws
    func recoverPassword(with email: String) async throws
    func changePassword(password: String, id: String) async throws
    func loginWithApple(code: String) async throws
    func loginWithGoogle(token: String) async throws
    func createAccount(fullName: String, email: String, password: String) async throws
}
