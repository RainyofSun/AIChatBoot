//
//  LRChatBootAILoadingButton.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/5.
//

import UIKit

class LRChatBootAILoadingButton: UIButton {

    private var activityIndicatorView: UIActivityIndicatorView?
    private var _btnTitle: String?
    private var _btnImg: UIImage?
    private var _btnAttributeTitle: NSAttributedString?
    
    deinit {
        deallocPrint()
    }
    
    public func startAnimation() {
        _btnTitle = self.currentTitle
        _btnAttributeTitle = self.currentAttributedTitle
        self.setTitle("", for: UIControl.State.normal)
        self.setAttributedTitle(NSAttributedString(string: ""), for: UIControl.State.normal)
        _btnImg = self.currentImage
        self.setImage(nil, for: UIControl.State.normal)
        
        let activityView = UIActivityIndicatorView.init(style: .medium)
        activityView.hidesWhenStopped = true
        activityView.startAnimating()
        activityView.alpha = 1
        activityView.color = WhiteColor
        self.addSubview(activityView)
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.activityIndicatorView = activityView
    }
    
    public func stopAnimation() {
        if let _activityView = self.activityIndicatorView {
            self.activityIndicatorView = nil
            UIView.animate(withDuration: 0.3) {
                _activityView.alpha = 0
            } completion: { _ in
                _activityView.stopAnimating()
                _activityView.removeFromSuperview()
            }
            self.setTitle(_btnTitle, for: UIControl.State.normal)
            self.setAttributedTitle(_btnAttributeTitle, for: UIControl.State.normal)
            self.setImage(_btnImg, for: UIControl.State.normal)
        }
    }

}
