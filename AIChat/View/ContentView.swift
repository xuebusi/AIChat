//
//  ContentView.swift
//  AIChat
//
//  Created by Mazen Kourouche on 2023/04/06.(https://youtu.be/WNBPFYWuPHo)
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ChatView()
            .environmentObject(ChatViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
