//
//  LRChatBootChatModel.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/30.
//

import UIKit
import HandyJSON
import WCDBSwift

struct LRChatBootChatModel: HandyJSON, TableCodable {
    /// 提问的问题(仅在AI回答的模型下有值)
    var askQuestion: String?
    /// 聊天内容
    var chatContent: String = ""
    /// 聊天时间
    var chatTime: String = Date().yearMonthDay1FormatString
    /// 聊天角色
    var chatRole: AIChatRole = .User
    /// 动画是否执行
    var animationComplete: Bool = false
    /// 等待AI回答
    var isWaittingForAIReply: Bool = true
    
    // MARK: DB
    /// 主键
    var identifier: Int?
    /// 用于定义是否使用自增的方式插入
    var isAutoIncrement: Bool = true
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = LRChatBootChatModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(identifier, isPrimary: true)
        }
        case identifier = "id"
        case chatContent = "chatContent"
        case chatTime = "chatTime"
        case chatRole = "chatRole"
        case animationComplete = "animationComplete"
        case isWaittingForAIReply = "isWaittingForAIReply"
        case askQuestion = "askQuestion"
    }
}
