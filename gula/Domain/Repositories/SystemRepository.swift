import Foundation

protocol SystemRepositoryProtocol {
    func checkCommandExists(_ command: String) async throws -> Bool
    func executeCommand(_ command: String) async throws -> String
}