//
//  LRChatBootChatNavView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/31.
//

import UIKit

protocol ChatBootChatNavProtocol: AnyObject {
    /// 点击返回
    func AI_chatBack()
    /// 点击静音
    func AI_ChatMute(isMute: Bool)
    /// 点击收藏
    func AI_collectTopic(animationView: UIButton)
}

class LRChatBootChatNavView: UIView {

    weak open var navDelegate: ChatBootChatNavProtocol?
    
    private lazy var backBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setImage(UIImage(named: "chat_icon_close"), for: UIControl.State.normal)
        btn.setImage(UIImage(named: "chat_icon_close"), for: UIControl.State.highlighted)
        btn.tintColor = WhiteColor
        return btn
    }()
    
    private lazy var titleLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.text = LRLocalizableManager.localValue("chatTitle")
        lab.textColor = WhiteColor
        lab.font = APPFont(20)
        return lab
    }()
    
    private lazy var volumBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setImage(UIImage(named: "chat_icon_volumeOpen"), for: UIControl.State.normal)
        btn.setImage(UIImage(named: "chat_icon_volumeMute"), for: UIControl.State.selected)
        return btn
    }()
    
    private lazy var likeBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setImage(UIImage(named: "chat_icon_dislike"), for: UIControl.State.normal)
        btn.setImage(UIImage(named: "chat_icon_like"), for: UIControl.State.selected)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadChatNavViews()
        layoutChatNavViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func resetMuteButtonStatus(isSelected: Bool) {
        self.volumBtn.isSelected = isSelected
    }
}

// MARK: Private Methods
private extension LRChatBootChatNavView {
    func loadChatNavViews() {
        
        self.backBtn.addTarget(self, action: #selector(clickBackBtn(sender: )), for: UIControl.Event.touchUpInside)
        self.volumBtn.addTarget(self, action: #selector(clickVolumeBtn(sender: )), for: UIControl.Event.touchUpInside)
        self.likeBtn.addTarget(self, action: #selector(clickLikeBtn(sender: )), for: UIControl.Event.touchUpInside)
        
        self.addSubview(self.backBtn)
        self.addSubview(self.titleLab)
        self.addSubview(self.volumBtn)
        self.addSubview(self.likeBtn)
    }
    
    func layoutChatNavViews() {
        
        self.backBtn.snp.makeConstraints { make in
            make.verticalEdges.left.equalToSuperview()
            make.size.equalTo(44)
        }
        
        self.titleLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backBtn)
        }
        
        self.likeBtn.snp.makeConstraints { make in
            make.centerY.equalTo(self.backBtn)
            make.right.equalToSuperview().offset(-20)
            make.size.equalTo(30)
        }
        
        self.volumBtn.snp.makeConstraints { make in
            make.centerY.equalTo(self.likeBtn)
            make.right.equalTo(self.likeBtn.snp.left).offset(-12)
            make.size.equalTo(self.likeBtn)
        }
    }
}

// MARK: Target
@objc private extension LRChatBootChatNavView {
    func clickBackBtn(sender: UIButton) {
        self.navDelegate?.AI_chatBack()
    }
    
    func clickVolumeBtn(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.navDelegate?.AI_ChatMute(isMute: sender.isSelected)
    }
    
    func clickLikeBtn(sender: UIButton) {
        self.navDelegate?.AI_collectTopic(animationView: sender)
    }
}
