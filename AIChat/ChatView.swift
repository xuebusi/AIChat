//
//  ChatView.swift
//  AIChat
//
//  Created by Mazen Kourouche on 2023/04/06.(https://youtu.be/WNBPFYWuPHo)
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { reader in
                    ScrollView(showsIndicators: false) {
                        ForEach(viewModel.messages.filter({$0.role != .system}), id: \.id) { message in
                            messageView(message: message)
                        }
                        .onChange(of: viewModel.messages) { (value) in
                            withAnimation {
                                reader.scrollTo(value.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
                HStack {
                    TextField("Enter a message...", text: $viewModel.currentInput)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        viewModel.sendMessage()
                    } label: {
                        if viewModel.isReceiving {
                            ProgressView()
                        } else {
                            Text("Send")
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isReceiving || viewModel.currentInput.isEmpty)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("ChatGPT", displayMode: .inline)
        }
    }
    
    func messageView(message: Message) -> some View {
        HStack {
            if message.role == .user { Spacer() }
            Text(message.content)
                .padding()
                .foregroundColor(message.role == .user ? Color.white : Color.primary)
                .background(message.role == .user ? Color.purple : Color.gray.opacity(0.2), in: .rect(cornerRadius: 10))
            if message.role == .assistant { Spacer() }
        }
        .id(message.id)
        .contextMenu() {
            // 长按复制
            HStack {
                Button {
                    let pastebord = UIPasteboard.general
                    pastebord.string = message.content
                } label: {
                    Text("拷贝")
                    Image(systemName: "doc.on.doc")
                }
            }
        }
    }
}

#Preview {
    ChatView()
}
