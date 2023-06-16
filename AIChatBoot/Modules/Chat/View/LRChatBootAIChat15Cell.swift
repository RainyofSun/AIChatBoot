//
//  LRChatBootAIChat15Cell.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/15.
//

import UIKit

@available(iOS 15.0, *)
class LRChatBootAIChat15Cell: LRChatBootAIChatCell {

    /// AI回复的全部文案
    open var AIReplayText: String {
        get {
            return self.contentLab.text ?? ""
        }
    }
    
    override func hookMenthods() {
        super.hookMenthods()
        self.contentLab.isHidden = false
        self.contentLab.font = UIFont.boldSystemFont(ofSize: 16)
        self.contentLab.textColor = WhiteColor
        self.contentLab.text = ""
    }
    
    override func reloadChatCellSource(chatModel: LRChatBootChatModel) {
        // 动画执行完毕
        if chatModel.animationComplete {
            if !chatModel.chatContent.isEmpty && self.contentLab.text?.isEmpty == true {
                self.contentLab.text = chatModel.chatContent
            }
            UIView.animate(withDuration: APPAnimationDurationTime, delay: .zero, options: UIView.AnimationOptions.curveEaseInOut) {
                self.shareBtn.alpha = 1
                self.copyBtn.alpha = 1
                self.refreshBtn.alpha = 1
            } completion: { _ in
                self.shareBtn.isEnabled = true
                self.copyBtn.isEnabled = true
                self.refreshBtn.isEnabled = true
                self.AIChatDelegate?.AI_animationComplete(isEnd: true, cellMark: self.cellMark)
            }
            return
        }
        
        self.shareBtn.alpha = CGFloat(NSNumber(booleanLiteral: chatModel.animationComplete).floatValue)
        self.copyBtn.alpha = CGFloat(NSNumber(booleanLiteral: chatModel.animationComplete).floatValue)
        self.refreshBtn.alpha = CGFloat(NSNumber(booleanLiteral: chatModel.animationComplete).floatValue)
        
        if self.indicatorView != nil {
            self.removeIndicatorView(activityView: self.indicatorView)
            self.indicatorView = nil
        }
        
        // 等待动画是否结束
        self.AIChatDelegate?.AI_indicatorAnimationComplete(isWaitting: chatModel.isWaittingForAIReply, cellMark: self.cellMark)
        if chatModel.isWaittingForAIReply {
            self.indicatorView = buildActivityIndicatorView(activityViewColor: UIColor.black)
            // 清空之前的文字
            self.contentLab.text = ""
            return
        }
    }
    
    // MARK: Public Methods
    /// 单纯刷新文字
    public func refreshAIReplyText(reply: String) {
        self.contentLab.text! += reply
    }
}
