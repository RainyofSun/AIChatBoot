//
//  LRWebNavigationProtocol.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/10/20.
//

import UIKit

/// 自定义Navigation 代理
protocol HSCustomWebNavigationProtocol: AnyObject {
    /// 点击返回
    func hs_webGoBack()
    /// 点击刷新
    func hs_webRefresh()
}

extension HSCustomWebNavigationProtocol {
    /// 点击刷新
    func hs_webRefresh() {
        Log.debug("点击刷新 --> 默认实现")
    }
}
