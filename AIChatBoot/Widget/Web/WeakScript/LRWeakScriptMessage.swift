//
//  LRWeakScriptMessage.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/10/19.
//

import UIKit
import WebKit

class LRWeakScriptMessage: NSObject {
    //MARK:- 属性设置 之前这个属性没有用weak修饰,所以一直持有,无法释放
    private weak var scriptDelegate: WKScriptMessageHandler!
    
    //MARK:- 初始化
    convenience init(scriptDelegate: WKScriptMessageHandler) {
        self.init()
        self.scriptDelegate = scriptDelegate
    }
    
    deinit {
        deallocPrint()
    }
}

extension LRWeakScriptMessage: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        scriptDelegate.userContentController(userContentController, didReceive: message)
    }
}



