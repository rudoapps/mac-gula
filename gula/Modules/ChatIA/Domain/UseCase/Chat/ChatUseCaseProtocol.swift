//
//  ChatUseCaseProtocol.swift
//  
//
//  Created by Axel Pérez Gaspar on 22/8/24.
//

import Foundation

protocol ChatUseCaseProtocol {
    func createChat(of customerID: Int) async throws -> Int
    func sendMessage(request: MessageRequest) async throws -> Message
    func getConfiguration(of customerID: Int) async throws -> ChatConfiguration
}
