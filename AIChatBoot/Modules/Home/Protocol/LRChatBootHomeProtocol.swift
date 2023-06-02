//
//  LRChatBootHomeProtocol.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit

protocol ChatBootTopicCellProtocol: AnyObject {
    /// 点击话题的标签分类
    func AI_selectedTopicClassification(classificationID: String?)
    /// 点击话题进入聊天
    func AI_selectedTopic(topicModel: LRChatBootTopicModel)
}

extension ChatBootTopicCellProtocol {
    /// 点击话题的标签分类
    func AI_selectedTopicClassification(classificationID: String?) {
        
    }
}
