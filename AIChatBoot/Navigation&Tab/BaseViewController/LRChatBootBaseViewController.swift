//
//  LRChatBootBaseViewController.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//

import UIKit

class LRChatBootBaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = MainBGColor
        self.addSystemNotification()
    }
    
    deinit {
        self.removeSystemNotification()
        deallocPrint()
    }
}

// MARK: Public Methods
extension LRChatBootBaseViewController {
    @discardableResult
    public func buildChatInputBoxView(canInput: Bool = false, inputDelegate delegate: ChatBootInputBoxProtocol? = nil) -> LRChatBootInputBoxView {
        let inputView: LRChatBootInputBoxView = LRChatBootInputBoxView(frame: CGRectZero)
        inputView.canInput = canInput
        inputView.inputDelegate = delegate
        self.view.addSubview(inputView)
        inputView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            if canInput {
                make.bottom.equalToSuperview()
            } else {
                make.bottom.equalToSuperview().offset(-tabBarHeight() - UIWindow.safeAreaBottom())
            }
        }
        
        return inputView
    }
}

// MARK: Subclass Implementation
@objc extension LRChatBootBaseViewController {
    func willEnterBackground(notification: Notification) {
        
    }
    
    func didBecomeActive(notification: Notification) {
        
    }
    
    func netStateChange(notification: Notification) {
        
    }
}

// MARK: Subclass Inheritance
@objc extension LRChatBootBaseViewController {
    // 添加系统通知
    func addSystemNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBackground(notification: )), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification: )), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(netStateChange(notification:)), name: .APPNetStateNotification, object: nil)
    }
    
    func removeSystemNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .APPNetStateNotification, object: nil)
    }
}
