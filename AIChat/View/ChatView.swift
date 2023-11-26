//
//  ChatView.swift
//  AIChat
//
//  Created by shiyanjun on 2023/11/17.
//

import SwiftUI

struct ChatView: View {
    @State var isKeyboard: Bool = false
    @EnvironmentObject var vm: ChatViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { reader in
                    ScrollView(showsIndicators: false) {
                        ForEach(vm.messages.filter({$0.role != .system}), id: \.id) { message in
                            messageView(message: message)
                        }
                        .onChange(of: vm.messages) { (value) in
                            withAnimation {
                                reader.scrollTo(value.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // 展示错误信息
                if vm.errorMessage != nil {
                    ErrorMessageView(errorMessage: $vm.errorMessage)
                }
                
                HStack {
                    Button(action: {
                        self.isKeyboard.toggle()
                    }, label: {
                        KeyboardView(isKeyboard: $isKeyboard)
                    })
                    
                    InputBoxView(isKeyboard: $isKeyboard)
                    
                    if isKeyboard {
                        Button {
                            if !vm.currentInput.isEmpty {
                                print(vm.currentInput)
                                vm.sendMessage()
                            }
                        } label: {
                            if vm.isReceiving {
                                ProgressView()
                            } else {
                                Text("Send")
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(vm.isReceiving || vm.currentInput.isEmpty)
                    }
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
                .background(message.role == .user ? Color.accentColor : Color.gray.opacity(0.2), in: .rect(cornerRadius: 10))
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

struct ErrorMessageView: View {
    @Binding var errorMessage: String?
    
    var body: some View {
        Text(errorMessage ?? "")
            .padding()
            .foregroundColor(.red)
            //.frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(.red.opacity(0.1))
            .cornerRadius(10)
            .overlay(alignment: .topTrailing, content: {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.black)
                    .padding()
                    .onTapGesture {
                        errorMessage = nil
                    }
            })
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
