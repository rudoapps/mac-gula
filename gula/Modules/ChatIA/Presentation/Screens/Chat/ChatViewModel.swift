//
//  ChatViewModel.swift
//
//
//  Created by Jorge on 23/7/24.
//

import Foundation

@Observable
final class ChatViewModel {
    private let useCase: ChatUseCaseProtocol
    private let router: ChatRouter
    private var messageToSend: String = ""
    private var chatID: Int?
    private var customerID: Int

    var messages: [Message] = []
    var newMessage: String = ""
    var configuration: ChatConfiguration?
    
    init(useCase: ChatUseCaseProtocol, customerID: Int, router: ChatRouter) {
        self.useCase = useCase
        self.customerID = customerID
        self.router = router
    }
}

@MainActor
extension ChatViewModel {
    func sendMessage() {
        messageToSend = newMessage
        if let lastMessage = messages.last,
           lastMessage.type == .error {
            messages.removeLast()
        }
        manageNewMessage()
        newMessage = ""
    }
    
    func resendMessage() {
        messages.removeLast(2)
        manageNewMessage()
    }
    
    func getConfiguration() {
        Task {
            do {
                configuration = try await useCase.getConfiguration(of: customerID)
            } catch {
                handle(this: error)
            }
        }
    }

    func checkIfCanSendMessage() {
        if !newMessage.isEmpty {
            sendMessage()
        }
    }
}

//MARK: - Private functions
@MainActor
private extension ChatViewModel {
    
    func manageNewMessage() {
        messages.append(Message(messageToSend, type: .user))
        messages.append(Message("escribiendo...", type: .loading))
        Task {
            do {
                if let chatID {
                    try await sendMessage(chatID: chatID)
                } else {
                    try await createChat()
                }
            } catch {
                handle(this: error)
            }
        }
    }
    
    func createChat() async throws {
        let chatID = try await useCase.createChat(of: customerID)
        try await sendMessage(chatID: chatID)
        self.chatID = chatID
    }
    
    func sendMessage(chatID: Int) async throws {
        let request = MessageRequest(chatID: chatID, message: messageToSend)
        let message = try await useCase.sendMessage(request: request)
        messages.removeLast()
        messages.append(message)
    }
    
    func handle(this error: Error) {
        messages.removeLast(2)
        messages.append(Message(messageToSend, type: .warning))
        if let error = error as? AppError,
           error == .noInternet {
            messages.append(Message("chat_PhoneWithoutConnection", type: .error))
        } else {
            messages.append(Message("chat_errorSendingMessage", type: .error))
        }
    }
}

extension ChatViewModel {
    func dismiss() {
        router.dismiss()
    }
}
