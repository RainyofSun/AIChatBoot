//
//  LRChatBootChatEnumFile.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/31.
//

import UIKit
import WCDBSwift

enum AIChatRole: Int, ColumnCodable,Equatable,CustomStringConvertible {
    case User
    case AI
    case Assistant
    
    static var columnType: ColumnType {
        return .integer64
    }
    
    func archivedValue() -> FundamentalValue {
        return FundamentalValue(Int64(self.rawValue))
    }
    
    init?(with value: FundamentalValue) {
        guard let object = AIChatRole(rawValue: Int(truncatingIfNeeded: value.int64Value)) else {
            return nil
        }
        self = object
    }
    
    var description: String {
        return "\(self.rawValue)"
    }
}
