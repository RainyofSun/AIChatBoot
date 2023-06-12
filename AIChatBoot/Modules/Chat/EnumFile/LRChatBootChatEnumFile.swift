//
//  LRChatBootChatEnumFile.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/31.
//

import UIKit
import WCDBSwift

enum AIChatRole: String, ColumnCodable,Equatable,CustomStringConvertible {
    /// 用户
    case User = "user"
    /// AI 机器人
    case AI = "assistant"
    /// 小助手
    case Assistant = "system"
    
    static var columnType: ColumnType {
        return .text
    }
    
    func archivedValue() -> FundamentalValue {
        return FundamentalValue(self.rawValue)
    }
    
    init?(with value: FundamentalValue) {
        guard let object = AIChatRole(rawValue: value.stringValue) else {
            return nil
        }
        self = object
    }
    
    var description: String {
        return "\(self.rawValue)"
    }
}
