//
//  LRChatBootLauncherWindow.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//

import UIKit

class LRChatBootLauncherWindow: UIWindow {

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        self.backgroundColor = UIColor.init(hexString: "#262949")
        self.frame = UIScreen.main.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resignKey() {
        super.resignKey()
        Log.debug("注销-------------")
    }
    
    deinit {
        deallocPrint()
    }

}
