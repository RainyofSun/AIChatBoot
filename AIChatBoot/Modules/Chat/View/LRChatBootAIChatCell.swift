//
//  LRChatBootAIChatCell.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/31.
//

import UIKit

class LRChatBootAIChatCell: LRChatBootChatCell {

    weak open var AIChatDelegate: ChatBootAIChatProtocol?
    
    private lazy var refreshBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.cornerRadius = 10
        btn.backgroundColor = WhiteColor.withAlphaComponent(0.8)
        btn.alpha = .zero
        return btn
    }()
    
    private lazy var copyBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.cornerRadius = 10
        btn.backgroundColor = WhiteColor.withAlphaComponent(0.8)
        btn.alpha = .zero
        return btn
    }()
    
    private lazy var shareBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.cornerRadius = 10
        btn.backgroundColor = WhiteColor.withAlphaComponent(0.8)
        btn.alpha = .zero
        return btn
    }()
    
    private var indicatorView: UIActivityIndicatorView?
    
    private let BTN_MIN_WIDTH: CGFloat = 95
    
    override func hookMenthods() {
        super.hookMenthods()
        self.contentView.backgroundColor = APPThemeColor
        self.userHeadImageView.image = UIImage(named: "chat_icon_system")
        self.refreshBtn.addTarget(self, action: #selector(clickRefrehBtn(sender: )), for: UIControl.Event.touchUpInside)
        self.copyBtn.addTarget(self, action: #selector(clickCopyBtn(sender: )), for: UIControl.Event.touchUpInside)
        self.shareBtn.addTarget(self, action: #selector(clickShareBtn(sender: )), for: UIControl.Event.touchUpInside)

        self.refreshBtn.setAttributedTitle(self.attributeTitle(title: LRLocalizableManager.localValue("chatRefresh"), iconName: "chat_icon_refresh"), for: UIControl.State.normal)
        self.refreshBtn.setAttributedTitle(self.attributeTitle(title: LRLocalizableManager.localValue("chatRefresh"), iconName: "chat_icon_refresh"), for: UIControl.State.highlighted)
        self.copyBtn.setAttributedTitle(self.attributeTitle(title: LRLocalizableManager.localValue("chatCopy"), iconName: "chat_icon_copy"), for: UIControl.State.normal)
        self.copyBtn.setAttributedTitle(self.attributeTitle(title: LRLocalizableManager.localValue("chatCopy"), iconName: "chat_icon_copy"), for: UIControl.State.highlighted)
        self.shareBtn.setAttributedTitle(self.attributeTitle(title: LRLocalizableManager.localValue("chatShare"), iconName: "chat_icon_share"), for: UIControl.State.normal)
        self.shareBtn.setAttributedTitle(self.attributeTitle(title: LRLocalizableManager.localValue("chatShare"), iconName: "chat_icon_share"), for: UIControl.State.highlighted)
        
        self.contentView.addSubview(self.refreshBtn)
        self.contentView.addSubview(self.copyBtn)
        self.contentView.addSubview(self.shareBtn)
        layoutAIChatViews()
    }
    
    override func animationStop() {
        super.animationStop()
        UIView.animate(withDuration: APPAnimationDurationTime, delay: .zero, options: UIView.AnimationOptions.curveEaseInOut) {
            self.shareBtn.alpha = 1
            self.copyBtn.alpha = 1
            self.refreshBtn.alpha = 1
        } completion: { _ in
            self.shareBtn.isEnabled = true
            self.copyBtn.isEnabled = true
            self.refreshBtn.isEnabled = true
        }
        
    }
    
    override func reloadChatCellSource(chatModel: LRChatBootChatModel) {

        self.shareBtn.alpha = CGFloat(NSNumber(booleanLiteral: chatModel.animationComplete).floatValue)
        self.copyBtn.alpha = CGFloat(NSNumber(booleanLiteral: chatModel.animationComplete).floatValue)
        self.refreshBtn.alpha = CGFloat(NSNumber(booleanLiteral: chatModel.animationComplete).floatValue)
        self.contentLab.attributedText = nil
        
        if self.indicatorView != nil {
            self.removeIndicatorView(activityView: self.indicatorView)
            self.indicatorView = nil
        }
        
        // 等待动画是否执行结束
        self.AIChatDelegate?.AI_indicatorAnimationComplete(isWaitting: chatModel.isWaittingForAIReply, cellMark: self.cellMark)
        if chatModel.isWaittingForAIReply {
            self.indicatorView = buildActivityIndicatorView(activityViewColor: UIColor.black)
            return
        }
        
        super.reloadChatCellSource(chatModel: chatModel)
    }
}

// MARK: Private Methods
private extension LRChatBootAIChatCell {
    func layoutAIChatViews() {
        self.contentLab.snp.remakeConstraints { make in
            make.left.equalTo(self.userHeadImageView.snp.right).offset(10)
            make.top.equalTo(self.userHeadImageView)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(self.shareBtn.snp.top).offset(-15)
        }
        
        self.shareBtn.snp.makeConstraints { make in
            make.right.equalTo(self.contentLab)
            make.bottom.equalToSuperview().offset(-15)
            make.width.greaterThanOrEqualTo(BTN_MIN_WIDTH)
            make.height.equalTo(36)
        }
        
        self.copyBtn.snp.makeConstraints { make in
            make.centerY.height.equalTo(self.shareBtn)
            make.width.greaterThanOrEqualTo(BTN_MIN_WIDTH)
            make.right.equalTo(self.shareBtn.snp.left).offset(-5)
        }
        
        self.refreshBtn.snp.makeConstraints { make in
            make.centerY.height.equalTo(self.shareBtn)
            make.width.greaterThanOrEqualTo(BTN_MIN_WIDTH)
            make.right.equalTo(self.copyBtn.snp.left).offset(-5)
        }
    }
    
    func attributeTitle(title: String, iconName: String) -> NSAttributedString {
        let _font: UIFont = UIFont.boldSystemFont(ofSize: 12)
        let _image: UIImage = UIImage(named: iconName)!
        let attachment: NSTextAttachment = NSTextAttachment(image: _image)
        attachment.bounds = CGRect(origin: CGPoint(x: .zero, y: (_font.capHeight - _image.size.height).rounded() * 0.5), size: _image.size)
        let attributeStr: NSMutableAttributedString = NSMutableAttributedString(string: " " + title, attributes: [.font: _font, .foregroundColor: UIColor(hexString: "#252949")])
        attributeStr.insert(NSAttributedString(attachment: attachment), at: .zero)
        return attributeStr
    }
}

// MARK: Target
@objc private extension LRChatBootAIChatCell {
    // 点击刷新
    func clickRefrehBtn(sender: UIButton) {
        // 禁用所有按钮
        sender.isEnabled = false
        self.copyBtn.isEnabled = false
        self.shareBtn.isEnabled = false
        self.AIChatDelegate?.AI_refreshAIReply(cellMark: self.cellMark)
    }
    
    // 点击复制
    func clickCopyBtn(sender: UIButton) {
        guard let _text = self.contentLab.text else {
            return
        }
        // https://qa.1r1g.com/sf/ask/1977169981/
        let string = self.contentLab.attributedText?.mutableCopy() as! NSMutableAttributedString
        string.addAttribute(.foregroundColor, value: UIColor.clear, range: NSRange(location: .zero, length: _text.count))
        UIView.transition(with: self.contentLab, duration: APPAnimationDurationTime, options: .transitionCrossDissolve, animations: {
            self.contentLab.attributedText = string
        }, completion: { _ in
            string.addAttribute(.foregroundColor, value: WhiteColor, range: NSRange(location: .zero, length: _text.count))
            UIView.transition(with: self.contentLab, duration: APPAnimationDurationTime, options: .transitionCrossDissolve, animations: {
                self.contentLab.attributedText = string
            })
        })
        
        self.AIChatDelegate?.AI_copyAIReply(replyContent: _text)
    }
    
    // 点击分享
    func clickShareBtn(sender: UIButton) {
        guard let _text = self.contentLab.text else {
            return
        }
        self.AIChatDelegate?.AI_shareReplyContent(content: _text)
    }
}
