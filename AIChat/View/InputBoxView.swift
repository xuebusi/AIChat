//
//  InputBoxView.swift
//  AIChat
//
//  Created by shiyanjun on 2023/11/17.
//

import SwiftUI

struct InputBoxView: View {
    @Binding var isKeyboard: Bool
    @EnvironmentObject var vm: ChatViewModel
    
    var body: some View {
        if isKeyboard {
            TextField("请输入文字...", text: $vm.currentInput)
                .textFieldStyle(.roundedBorder)
        } else {
            SpeechToTextView()
        }
    }
}

struct InputBoxView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
