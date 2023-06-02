//
//  LRChatBootExploreProtocol.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit

protocol ChatBootExploreSliderProtocol: AnyObject {
    /// 点击话题的标签分类
    func AI_selectedTopicClassification(classificationID: String?, classifyIndex: Int)
}
