//
//  LRChatBootStringBackToOrderAnimation.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//

import UIKit

class LRChatBootStringBackToOrderAnimation: LRChatBootStringAnimation {
    
    /// 动画时间
    open var duration: TimeInterval = 1
    
    private var charLabels : [CharLabel]?
    
    override func startAnimation(for targetView : UIView) {
        self.targetView = targetView
        guard  let targetLabel = targetView as? UILabel else {
            return
        }
        targetLabel.isHidden = true
        //guard let text = targetLabel.text else {return}
        print(targetLabel.animation_textBounds()!)
        //print(targetLabel.ff_linesForWidth(targetLabel.ff_textBounds()!.size.width))
        print(targetLabel.animation_lines())
        guard let superView = targetLabel.superview else {return}
        charLabels = targetLabel.animation_charLabels()
        for charLabel in charLabels!{
            charLabel.old_center = CGPoint(x: charLabel.center.x, y: charLabel.center.y)
            charLabel.center.x = CGFloat(arc4random_uniform(UInt32(targetLabel.frame.size.width)))
            charLabel.center.y = CGFloat(arc4random_uniform(UInt32(targetLabel.frame.size.height)))
            superView.addSubview(charLabel)
        }
        
        UIView.animate(withDuration: duration, delay: .zero, options: UIView.AnimationOptions.curveEaseInOut) {
            for charLabel in self.charLabels!{
                if charLabel.old_center != nil{
                    charLabel.center = charLabel.old_center!
                }
            }
        }
    }
}
