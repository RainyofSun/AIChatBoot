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
    var topicClassification: String?
    /// 话题分类ID
    var topicClassificationID: String?
    /// 话题热度
    var hotTopics: String?
    /// 话题内容
    var topic: String?
    /// 话题ID
    var topicID: String?
    /// 话题图片
    var topicImageURL: String?
    /// 分类颜色
    var categoryColor: String?
    /// 是否喜欢话题
    var likeIssue: Bool = false
    /// 是否收藏
    var collectIssue: Bool = false
    /// 是否根据用户输入内容自动生成
    var generatedBasedOnUserInput: Bool = false
    /// 聊天时间
    var chatTime: String = Date().yearMonthDay1FormatString
    /// 自建聊天记录ID(当存储聊天记录的时候,创建ID,以此ID来创建不同聊天记录的数据表, Date().millisecondTimestampStringValue)
    var chatRecordID: String?
    /// 当前话题下总共有多少条聊天消息(用于判断下拉加载更多聊天消息,是否拉取完毕)
    var totalNumberOfChatMessages: Int = .zero
    
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
        case categoryColor = "categoryColor"
        case likeIssue = "likeIssue"
        case collectIssue = "collectIssue"
        case generatedBasedOnUserInput = "generatedBasedOnUserInput"
        case totalNumberOfChatMessages = "totalNumberOfChatMessages"
    }
    
    mutating func mapping(mapper: HelpingMapper) {
        // 替换字段
        mapper.specify(property: &topicClassification, name: "categoryName") { (name: String) in
            return "# " + name
        }
        mapper.specify(property: &topicClassificationID, name: "categoryId")
        mapper.specify(property: &topic, name: "content.issueContent")
        mapper.specify(property: &topicImageURL, name: "issuePromptImageUrl") { (url: String) in
            return CDN_PREFFIX + url
        }
        mapper.specify(property: &topicID, name: "issueId")
        mapper.specify(property: &hotTopics, name: "hotIssue") { (hot: String) in
            return hot.digitalConversionMillionOrBillion()
        }
    }
    
    /// 根据用户输入内容自动生成
    static func generatedBasedOnUserInput(topic: String) -> LRChatBootTopicModel {
        var model = LRChatBootTopicModel()
        model.topic = topic
        // 自定话题ID ---> 生成话题的时间戳
        model.topicID = Date().secondTimestampStringValue
        model.generatedBasedOnUserInput = true
        return model
    }
}
