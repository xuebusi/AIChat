//
//  ChatViewModel.swift
//  AIChat
//
//  Created by Mazen Kourouche on 2023/04/06.(https://youtu.be/WNBPFYWuPHo)
//

import SwiftUI

extension ChatView {
    class ViewModel: ObservableObject {
        @Published var messages: [Message] = [Message(id: UUID(), role: .system, content: "You are coding assistand. You will help me understand how to write only Swift code. You do not have enough information about other languages to give advice so avoid doing so at ALL times", createAt: Date())]
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
