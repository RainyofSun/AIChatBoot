//
//  LRChatBootSubscribeButton.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/5.
//

import UIKit

class LRChatBootSubscribeButton: UIControl {

    private lazy var titleLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.textColor = APPThemeColor
        lab.font = APPFont(19)
        lab.text = LRLocalizableManager.localValue("subscribeWeekly")
        return lab
    }()
    
    private lazy var subTitleLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.textColor = APPThemeColor
        lab.font = APPFont(19)
        lab.text = LRLocalizableManager.localValue("subscribePrice")
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadButtonViews()
        layoutButtonViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func updatePrice(price: String) {
        self.subTitleLab.text = price
    }
}

// MARK: Private methods
private extension LRChatBootSubscribeButton {
    func loadButtonViews() {
        self.backgroundColor = WhiteColor.withAlphaComponent(0.06)
        self.cornerRadius = 20
        
        self.addSubview(self.titleLab)
        self.addSubview(self.subTitleLab)
    }
    
    func layoutButtonViews() {
        self.titleLab.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(22)
            make.left.equalToSuperview().offset(30)
        }
        
        self.subTitleLab.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLab)
            make.right.equalToSuperview().offset(-30)
        }
    }
}
