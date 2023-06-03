//
//  LRChatBootTopicModel.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit
import HandyJSON
import WCDBSwift

struct LRChatBootTopicModel: HandyJSON, TableCodable {
    /// 话题分类
    var topicClassification: String? {
        didSet {
            if let _t_c = topicClassification {
                topicClassification = "# " + _t_c
            }
        }
    }
    /// 话题分类ID
    var topicClassificationID: String?
    /// 话题热度
    var hotTopics: String? {
        didSet {
            if let _hot = hotTopics {
                hotTopics = _hot.digitalConversionMillionOrBillion()
            }
        }
    }
    /// 话题内容
    var topic: String?
    /// 话题ID
    var topicID: String?
    /// 话题图片
    var topicImageURL: String?
    /// 聊天时间
    var chatTime: String = Date().yearMonthDay1FormatString
    /// 自建聊天记录ID(当存储聊天记录的时候,创建ID,以此ID来创建不同聊天记录的数据表, Date().millisecondTimestampStringValue)
    var chatRecordID: String?
    
    // MARK: DB
    /// 主键
    var identifier: Int?
    /// 用于定义是否使用自增的方式插入
    var isAutoIncrement: Bool = true
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = LRChatBootTopicModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(identifier, isPrimary: true)
        }
        case identifier = "id"
        case topicClassification = "topicClassification"
        case topicClassificationID = "topicClassificationID"
        case hotTopics = "hotTopics"
        case chatTime = "chatTime"
        case topicImageURL = "topicImageURL"
        case topicID = "topicID"
        case topic = "topic"
        case chatRecordID = "chatRecordID"
    }
}
