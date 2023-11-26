//
//  OpenAIService.swift
//  AIChat
//
//  Created by Mazen Kourouche on 2023/04/06.(https://youtu.be/WNBPFYWuPHo)
//

// [请求示例]:
//
//  {
//    "model": "gpt-3.5-turbo",
//    "messages": [
//      {
//        "role": "system",
//        "content": "You are a helpful assistant."
//      },
//      {
//        "role": "user",
//        "content": "你好！"
//      }
//    ]
//  }

// [响应示例]:
//
//    {
//        "id": "chatcmpl-8PBO1ngPu2N12RJRhj7JpZIIhwNsy",
//        "object": "chat.completion",
//        "created": 1701012661,
//        "model": "gpt-3.5-turbo-0613",
//        "choices": [
//            {
//                "index": 0,
//                "message": {
//                    "role": "assistant",
//                    "content": "你好！有什么我可以帮助你的吗？"
//                },
//                "finish_reason": "stop"
//            }
//        ],
//        "usage": {
//            "prompt_tokens": 20,
//            "completion_tokens": 18,
//            "total_tokens": 38
//        }
//    }
import Alamofire

class OpenAIService {
    private let endpointUrl = "https://api.openai.com/v1/chat/completions"
    
    /// 发送消息
    func sendMessage(messages: [Message]) async -> Result<OpenAIChatResponse, Error> {
        let openAIMessages = messages.map({OpenAIChatMessage(role: $0.role, content: $0.content)})
        let body = OpenAIChatBody(model: "gpt-3.5-turbo", messages: openAIMessages)
        let headers: HTTPHeaders = ["Authorization": "Bearer \(Constants.openAIApiKey)"]
        
        //    do {
        //        let response = try await AF.request(endpointUrl, method: .post, parameters: body, encoder: .json, headers: headers)
        //            .serializingDecodable(OpenAIChatResponse.self).value
        //        return .success(response)
        //    } catch {
        //        print("OpenAI Service Error: \(error)")
        //        return .failure(error)
        //    }
        
        let dataRequest = AF.request(endpointUrl, method: .post, parameters: body, encoder: .json, headers: headers)
        
        do {
            let successResponse = try await dataRequest.serializingDecodable(OpenAIChatResponse.self).value
            return .success(successResponse)
        } catch {
            //    {
            //        "error": {
            //            "message": "Incorrect API key provided: sk-g4ueP***************************************n9sn. You can find your API key at https://platform.openai.com/account/api-keys.",
            //            "type": "invalid_request_error",
            //            "param": null,
            //            "code": "invalid_api_key"
            //        }
            //    }
            do {
                let errorResponse = try await dataRequest.serializingDecodable(OpenAIErrorResponse.self).value
                return .failure(CustomError.error_info(errorResponse.error.message))
            } catch {
                return .failure(error)
            }
        }
    }
}

enum CustomError: Error {
    case error_info(String)
}

struct OpenAIChatBody: Encodable {
    let model: String
    let messages: [OpenAIChatMessage]
}

struct OpenAIChatMessage: Codable {
    let role: SenderRole
    let content: String
}

enum SenderRole: String, Codable {
    case system
    case user
    case assistant
}

struct OpenAIChatResponse: Decodable {
    let choices: [OpenAIChatChoice]
}

struct OpenAIChatChoice: Decodable {
    let message: OpenAIChatMessage
}


struct OpenAIErrorResponse: Decodable {
    let error: OpenAIErrorMessage
}

struct OpenAIErrorMessage: Decodable {
    let message: String
}
