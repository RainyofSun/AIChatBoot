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
    /// AIChatAnimation (AI回答是否要使用动画)
    var AIChatAnimation: Bool = false
    /// 动画是否执行
    var animationComplete: Bool = false
    /// 等待AI回答
    var isWaittingForAIReply: Bool = true
    /// 聊天消息编号(用于下拉加载更多消息使用)
    var chatSerialNumber: Int = .zero
    
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
        case chatSerialNumber = "chatSerialNumber"
        case AIChatAnimation = "AIChatAnimation"
    }
    
    // MARK: Public Methods
    /// 抽取用户询问的问题
    public func questionAskedByUser() -> [String: String] {
        return ["content": self.chatContent, "role": self.chatRole.rawValue]
    }
}
