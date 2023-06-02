//
//  LRChatBootExploreSliderItem.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit

class LRChatBootExploreSliderItem: UIButton {

    /// 分类ID
    open var classificationID: String?
    
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? APPThemeColor : UIColor(hexString: "#1A1A1A")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadItemViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
}

// MARK: Private Methods
private extension LRChatBootExploreSliderItem {
    func loadItemViews() {
        self.cornerRadius = 18
        self.backgroundColor = UIColor(hexString: "#1A1A1A")
        self.setTitleColor(UIColor(hexString: "#AAAAAA"), for: UIControl.State.normal)
        self.setTitleColor(WhiteColor, for: UIControl.State.selected)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    }
}
