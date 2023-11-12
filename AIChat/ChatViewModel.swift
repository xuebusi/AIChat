//
//  ChatViewModel.swift
//  AIChat
//
//  Created by Mazen Kourouche on 2023/04/06.(https://youtu.be/WNBPFYWuPHo)
//

import SwiftUI

extension ChatView {
    class ViewModel: ObservableObject {
        @Published var messages: [Message] = [Message(id: UUID(), role: .system, content: "你是一个万能助理，可以帮我解决各种问题。请始终使用简体中文回答我。", createAt: Date())]
        @Published var currentInput: String = ""
        @Published var isReceiving: Bool = false
        
        private let openAIService = OpenAIService()
        
        func sendMessage() {
            let newMessage = Message(id: UUID(), role: .user, content: currentInput, createAt: Date())
            messages.append(newMessage)
            currentInput = ""
            isReceiving = true
            
            Task {
                let response = await openAIService.sendMessage(messages: messages)
                guard let receivedOpenAIMessage = response?.choices.first?.message else {
                    print("Had no received message")
                    return
                }
                let receiveMessage = Message(id: UUID(), role: receivedOpenAIMessage.role, content: receivedOpenAIMessage.content, createAt: Date())
                await MainActor.run {
                    messages.append(receiveMessage)
                    isReceiving = false
                }
            }
        }
    }
}

struct Message: Decodable, Equatable {
    let id: UUID
    let role: SenderRole
    let content: String
    let createAt: Date
}
