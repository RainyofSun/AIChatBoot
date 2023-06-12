//
//  LRChatBootChatProtocol.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/31.
//

import UIKit

// MARK: Cell动画代理
protocol ChatBootAIChatAnimationProtocol: AnyObject {
    /// 动画执行结束
    func AI_animationComplete(isEnd: Bool, cellMark: IndexPath?)
    /// 等待动画执行结束
    func AI_indicatorAnimationComplete(isWaitting: Bool, cellMark: IndexPath?)
}

extension ChatBootAIChatAnimationProtocol {
    /// 等待动画执行结束
    func AI_indicatorAnimationComplete(isWaitting: Bool, cellMark: IndexPath?) {
        
    }
}

// MARK: AI回复的操作代理
protocol ChatBootAIChatProtocol: ChatBootAIChatAnimationProtocol {
    /// 刷新AI回复
    func AI_refreshAIReply(cellMark: IndexPath?)
    /// 复制AI回复
    func AI_copyAIReply(replyContent: String)
    /// 分享AI回复
    func AI_shareReplyContent(content: String)
}
