//
//  AuthDataSource.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 10/7/24.
//

import Foundation
import TripleA

@available(macOS 15.0, *)
class AuthRemoteDataSource: AuthRemoteDataSourceProtocol {
    private let network: Network

    init(network: Network) {
        self.network = network
    }

    func login(with email: String, and password: String) async throws {
        let parameters = ["username": email,
                          "password": password]
        try await self.network.authenticator?.getNewToken(with: parameters, endpoint: nil)
    }

    func loginWithApple(code: String) async throws {
        let parameters = ["auth_code": code]
        let endpoint = Endpoint(path: "\(Config.baseURL)api/users/login/apple", httpMethod: .post)
        try await self.network.authenticator?.getNewToken(with: parameters, endpoint: endpoint)
    }

    func loginWithGoogle(token: String) async throws {
        let parameters = ["access_token": token,
                          "provider": "google-oauth2-idtoken"]
        let endpoint = Endpoint(path: "\(Config.baseURL)api/gula/auth/social-login", httpMethod: .post)
        try await self.network.authenticator?.getNewToken(with: parameters, endpoint: endpoint)
    }

    func recoverPassword(with email: String) async throws {
        let parameters = ["email": email]
        let endpoint = Endpoint(path: "api/users/recover-password", httpMethod: .post, parameters: parameters)
        _ = try await network.load(this: endpoint)
    }

    func changePassword(password: String, id: String) async throws {
        let parameters = ["new_password": password,
                          "suid": id]
        let endpoint = Endpoint(path: "api/users/change-password", httpMethod: .put, parameters: parameters)
        _ = try await network.load(this: endpoint)
    }

    func createAccount(fullName: String, email: String, password: String) async throws {
        let parameters = ["fullname": fullName,
                          "email": email,
                          "password": password]
        let endpoint = Endpoint(path: "api/users/create", httpMethod: .post, parameters: parameters)
        _ = try await network.load(this: endpoint)
    }
}
