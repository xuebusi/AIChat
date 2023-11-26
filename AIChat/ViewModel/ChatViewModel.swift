//
//  ChatViewModel.swift
//  AIChat
//
//  Created by Mazen Kourouche on 2023/04/06.(https://youtu.be/WNBPFYWuPHo)
//

import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [Message(id: UUID(), role: .system, content: "你是一个万能助理，可以帮我解决各种问题。请始终使用简体中文回答我。", createAt: Date())]
    @Published var currentInput: String = ""
    @Published var isReceiving: Bool = false
    @Published var errorMessage: String? // 用于存储错误信息
    @Published var errorLog: String? // 用于存储错误日志
    
    private let openAIService = OpenAIService()
    
    func sendMessage() {
        let newMessage = Message(id: UUID(), role: .user, content: currentInput, createAt: Date())
        messages.append(newMessage)
        currentInput = ""
        isReceiving = true
        
        Task {
            let result = await openAIService.sendMessage(messages: messages)
            switch (result) {
            case .success(let response):
                guard let receivedOpenAIMessage = response.choices.first?.message else {
                    print("Had no received message")
                    return
                }
                let receiveMessage = Message(id: UUID(), role: receivedOpenAIMessage.role, content: receivedOpenAIMessage.content, createAt: Date())
                await MainActor.run {
                    messages.append(receiveMessage)
                    isReceiving = false
                }
            case .failure(CustomError.error_info(let errorMsg)):
                await MainActor.run {
                    isReceiving = false
                    errorMessage = errorMsg
                }
            case .failure(let error):
                await MainActor.run {
                    print(error.localizedDescription)
                    isReceiving = false
                    errorMessage = "网络错误，请检查网络连接！"
                }
            }
        }
    }
}

