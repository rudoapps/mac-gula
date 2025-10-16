//
//  AuthUseCase.swift
//  Gula
//
//  Created by Jorge Planells Zamora on 5/7/24.
//

import Foundation

enum AuthError: DetailErrorProtocol {
    var title: String {
        switch self {
        case .notVerified:
            "auth_notVerifiedTitle"
        case .appError(let title, _):
            title
        case .inputEmailError, .inputPasswordError, .inputUsernameError, .inputsError:
            ""
        }
    }

    var message: String {
        switch self {
        case .appError(_, let message):
            message
        case .notVerified:
            "auth_notVerifiedMessage"
        case .inputEmailError:
            "auth_wrongEmailFormat"
        case .inputPasswordError:
            "auth_wrongPassword"
        case .inputUsernameError(let message):
            message
        case .inputsError:
            ""
        }
    }

    case inputEmailError(String)
    case inputPasswordError(String)
    case inputUsernameError(String)
    case inputsError([String], [String])
    case appError(String, String)
    case notVerified
}

class AuthUseCase: AuthUseCaseProtocol {
    // MARK: - Properties
    var repository: AuthRepositoryProtocol

    // MARK: - Init
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Functions
    func login(with email: String, and password: String) async throws {
        do {
            try await repository.login(with: email, and: password)
        } catch let error as AppError {
            throw handle(error)
        }
    }

    func recoverPassword(with email: String) async throws {
        do {
            try await repository.recoverPassword(with: email)
        } catch let error as AppError {
            throw handle(error)
        }
    }

    func changePassword(password: String, id: String) async throws {
        do {
            try await repository.changePassword(password: password, id: id)
        } catch let error as AppError {
            throw handle(error)
        }
    }

    func loginWithApple(code: String) async throws {
        do {
            try await repository.loginWithApple(code: code)
        } catch let error as AppError {
            throw handle(error)
        }
    }

    func loginWithGoogle(token: String) async throws {
        do {
            try await repository.loginWithGoogle(token: token)
        } catch let error as AppError {
            throw handle(error)
        }
    }

    func createAccount(fullName: String, email: String, password: String) async throws {
        do {
            try await repository.createAccount(fullName: fullName, email: email, password: password)
        } catch let error as AppError {
            throw handle(error)
        }
    }
}

private extension AuthUseCase {
    func handle(_ error: AppError) -> AuthError {
        switch error {
        case .customError(_, let statusCode):
            if statusCode == 403 {
                return AuthError.notVerified
            }
            return AuthError.appError(error.title, error.message)
        case .inputError(let field, let message):
            switch field {
            case "email":
                return .inputEmailError(message)
            case "password":
                return .inputPasswordError(message)
            case "username":
                return .inputUsernameError(message)
            default:
                return .appError("tryAgain", "generalError")
            }
        case .inputsError(let fields, let messages):
            return .inputsError(fields, messages)
        case .badCredentials, .noInternet, .generalError:
            return AuthError.appError(error.title, error.message)
        }
    }
}
