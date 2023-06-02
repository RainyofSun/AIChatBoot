//
//  LRChatBootTopicModel.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit
import HandyJSON

struct LRChatBootTopicModel: HandyJSON {
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
    /// 话题图片
    var topicImageURL: String?
    /// 聊天时间
    var chatTime: String = Date().yearMonthDay1FormatString
}
