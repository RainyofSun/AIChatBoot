//
//  LRChatBootChatModel.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/30.
//

import UIKit
import HandyJSON

struct LRChatBootChatModel: HandyJSON {
    /// 聊天内容
    var chatContent: String = ""
    /// 聊天时间
    var chatTime: String = Date().yearMonthDay1FormatString
    /// 聊天角色
    var chatRole: AIChatRole = .User
}
