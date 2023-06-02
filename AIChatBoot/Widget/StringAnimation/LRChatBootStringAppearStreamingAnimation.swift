//
//  LRChatBootStringAppearStreamingAnimation.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/26.
//

import UIKit

class LRChatBootStringAppearStreamingAnimation: LRChatBootStringAnimation {
    
    private var _charIndex: Int = .zero
    private var _charString: String = ""
    private var mutableString: NSMutableAttributedString?
    private var textLayer: CATextLayer?
    
    override func startAnimation(for targetView: UIView) {
        
        self.targetView = targetView
        guard let _targetLab = targetView as? UILabel, let _targetLabText = _targetLab.text, let _targetSuperLayer = _targetLab.superview?.layer, let _textFrame = _targetLab.animation_streamTextFrame() else {
            return
        }
        self._charString = _targetLabText
        
        _targetLab.isHidden = true
        let _textLayer: CATextLayer = CATextLayer()
        _textLayer.frame = _targetLab.layer.convert(_textFrame, to: _targetSuperLayer)
        _textLayer.contentsScale = UIScreen.main.scale
        
        var _textAlignmentModel: CATextLayerAlignmentMode = CATextLayerAlignmentMode.left
        switch _targetLab.textAlignment {
        case .left:
            _textAlignmentModel = .left
        case .right:
            _textAlignmentModel = .right
        case .center:
            _textAlignmentModel = .center
        case .justified:
            _textAlignmentModel = .justified
        case .natural:
            _textAlignmentModel = .natural
        @unknown default:
            _textAlignmentModel = .left
        }
        
        _textLayer.alignmentMode = _textAlignmentModel
        _textLayer.isWrapped = true
        _targetSuperLayer.addSublayer(_textLayer)
        self.textLayer = _textLayer
        
        let _attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.clear, .font: _targetLab.font ?? UIFont.systemFont(ofSize: 15)]
        self.mutableString = NSMutableAttributedString(string: _targetLabText, attributes: _attributes)
        
        super.startAnimation(for: targetView)
    }
    
    /// 执行动画
    override func displayAnimation() {
        super.displayAnimation()
        guard let _targetLab = self.targetView as? UILabel else {
            return
        }
        
        self.mutableString?.addAttributes([.foregroundColor: _targetLab.textColor ?? UIColor.black, .font: _targetLab.font ?? UIFont.systemFont(ofSize: 15)], range: NSRange(location: _charIndex, length: 1))
        self.textLayer?.string = self.mutableString
        
        _charIndex += 1
        if _charIndex == _charString.count {
            self.stopAnimation()
        }
    }
    
    override func stopAnimation() {
        super.stopAnimation()
        DispatchQueue.main.async {
            self.textLayer?.removeFromSuperlayer()
            self.textLayer = nil
            self.targetView?.isHidden = false
        }
    }
}
