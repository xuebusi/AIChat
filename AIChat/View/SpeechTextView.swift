//
//  SpeechToTextView.swift
//  AIChat
//
//  Created by shiyanjun on 2023/11/17.
//

import SwiftUI
import Speech

struct SpeechToTextView: View {
    @EnvironmentObject var vm: ChatViewModel
    @State private var isRecording = false
    // 添加一个状态标志来跟踪录音是否已停止
    @State private var hasStoppedRecording = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private let audioEngine = AVAudioEngine()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    
    var body: some View {
        // 录音按钮
        Button {
            // 此处不需要执行任何操作，手势识别器将处理所有操作
        } label: {
            Text("按住说话")
                .padding(.vertical, 15)
        }
        //.buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity)
        .background(Color.accentColor)
        .foregroundColor(.white)
        .cornerRadius(10)
        .disabled(isRecording)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in
                    if !self.isRecording {
                        print("startRecording...")
                        self.startRecording()
                    }
                })
                .onEnded({ _ in
                    if self.isRecording {
                        self.stopRecording()
                        print("stopRecording...")
                        if !vm.currentInput.isEmpty {
                            vm.sendMessage()
                        }
                    }
                })
        )
    }
    
    // 开始录音的函数
    private func startRecording() {
        // 确保没有正在进行的录音
        if isRecording {
            stopRecording()
        }
        
        isRecording = true
        recognitionTask?.cancel()
        hasStoppedRecording = false // 在开始录音时重置此标志
        self.recognitionTask = nil
        
        // 配置音频会话
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("设置音频会话属性时发生错误: \(error)")
            return
        }
        
        // 创建语音识别请求
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("无法创建请求实例")
        }
        
        // 实时报告部分结果
        recognitionRequest.shouldReportPartialResults = true
        
        // 处理语音识别任务
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result, !self.hasStoppedRecording {
                // 更新识别出的文本
                self.vm.currentInput = result.bestTranscription.formattedString
                print("recognizedText:\(self.vm.currentInput)")
            }
            if error != nil || result?.isFinal == true {
                // 结束录音和语音识别
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.isRecording = false
                self.hasStoppedRecording = true
            }
        }
        
        // 配置并启动音频引擎
        let inputNode = audioEngine.inputNode
        // 在安装新的 tap 前先移除现有的
        inputNode.removeTap(onBus: 0)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("音频引擎启动错误: \(error)")
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()  // 取消语音识别任务
        recognitionTask = nil      // 清空语音识别任务
        recognitionRequest = nil   // 清空语音识别请求
        isRecording = false
        hasStoppedRecording = true // 设置标志表示录音已停止
    }
    
}

struct SpeechToTextView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechToTextView()
    }
}
