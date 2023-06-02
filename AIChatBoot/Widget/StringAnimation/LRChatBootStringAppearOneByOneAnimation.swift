//
//  LRChatBootStringAppearOneByOneAnimation.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//

import UIKit

class LRChatBootStringAppearOneByOneAnimation: LRChatBootStringAnimation {

    private var charLabels : [CharLabel]?
    private var next = 0
    private var animating = false
    
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
            charLabel.alpha = 0
            superView.addSubview(charLabel)
        }
        next = 0
        super.startAnimation(for: targetView)
    }
    
    override func displayAnimation() {
        super.displayAnimation()
        if animating{
            return
        }
        guard let charLabels = self.charLabels else {return}
        let charLabel = charLabels[next]
        animating = true
        
        UIView.animate(withDuration: self.appearDuration, delay: .zero, options: UIView.AnimationOptions.curveEaseIn) {
            charLabel.alpha = 1
        } completion: { done in
            self.animating = false
        }

        next += 1
        if next == charLabels.count{
            if self.animationLoop{
                for charLabel in charLabels{
                    charLabel.alpha = 0
                }
                next = 0
            }else{
                self.stopAnimation()
            }
        }
    }
    
    override func stopAnimation() {
        super.stopAnimation()
        self.targetView?.isHidden = false
        self.charLabels?.forEach({ (item: CharLabel) in
            item.removeFromSuperview()
        })
        self.charLabels?.removeAll()
        self.charLabels = nil
    }
}
