//
//  LRChatBootLikeTopicCell.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit

class LRChatBootLikeTopicCell: LRChatBootTopicCell {
    
    override func hookMethods() {
        super.hookMethods()
        self.hotLab.isHidden = true
        self.contentLab.numberOfLines = 3
    }
    
    override func reloadTopicCellSource(model: LRChatBootTopicModel) {
        super.reloadTopicCellSource(model: model)
        self.bgImageView.backgroundColor = .orange.withAlphaComponent(0.4)
    }
}
