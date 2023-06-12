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
        self.bgImageView.isHidden = false
        self.hotLab.isHidden = true
        self.contentLab.numberOfLines = 3
    }
    
    override func reloadTopicCellSource(model: LRChatBootTopicModel, showBgImage: Bool = true) {
        super.reloadTopicCellSource(model: model, showBgImage: showBgImage)
        self.bgImageView.backgroundColor = UIColor(hexString: model.categoryColor ?? "#C4D160")
    }
}
