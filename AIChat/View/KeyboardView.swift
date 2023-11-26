//
//  KeyboardView.swift
//  AIChat
//
//  Created by shiyanjun on 2023/11/17.
//

import SwiftUI

// 键盘按钮组件
struct KeyboardView: View {
    @Binding var isKeyboard: Bool
    
    var body: some View {
        if isKeyboard {
            // 录音按钮
            Image(systemName: "mic.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 28)
        } else {
            // 键盘按钮
            Image(systemName: "keyboard")
                .resizable()
                .scaledToFit()
                .frame(width: 28)
        }
    }
}

struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
