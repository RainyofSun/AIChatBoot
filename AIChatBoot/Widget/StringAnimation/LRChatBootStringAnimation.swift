//
//  LRChatBootStringAnimation.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//

import UIKit

class LRChatBootStringAnimation: NSObject {
    
    // 动画结束回调
    open var animationComplete: (() ->Void)?
    weak open var targetView : UIView?
    // 动画是否循坏执行
    open var animationLoop = false
    // 字符动画的时间
    open var appearDuration : TimeInterval = 0.2
    // 动画速率(0 最快)
    open var animationRate: Int = .zero
    
    private(set) var linkTimer : CADisplayLink?
    
    // MARK: Subclass Inheritance
    public func startAnimation(for targetView:UIView){
        linkTimer = CADisplayLink(target: self, selector: #selector(displayAnimation))
        linkTimer?.preferredFramesPerSecond = animationRate
        linkTimer?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
    @objc public func displayAnimation() {
        
    }
    
    public func stopAnimation(){
        linkTimer?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
        linkTimer?.invalidate()
        linkTimer = nil
        self.animationComplete?()
    }
    
    deinit {
        deallocPrint()
    }
}

extension NSString{
    func string_sizeWithFont(_ font : UIFont) -> CGSize{
        return self.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:font], context: nil).size
    }
}
