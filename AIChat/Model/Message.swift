//
//  Message.swift
//  AIChat
//
//  Created by shiyanjun on 2023/11/17.
//

import Foundation

struct Message: Decodable, Equatable {
    let id: UUID
    let role: SenderRole
    let content: String
    let createAt: Date
}
