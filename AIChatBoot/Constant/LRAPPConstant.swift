//
//  LRAPPConstant.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/13.
//

import UIKit

// MARK: 程序常量
/// 隐私政策
let APPPrivacy: String = "http://www.conhor.pro/privacystatement/storagecleaner/privacyPolicy.html"
/// 服务条款
let APPService: String = "http://www.conhor.pro/privacystatement/storagecleaner/termsofuse.html"

// MARK: 动画时间常量
let APPAnimationDurationTime: TimeInterval = 0.3

// MARK: 自定义字体
func APPFont(_ size: CGFloat = 14) -> UIFont {
    return UIFont.init(name: "Arial Black", size: size) ?? UIFont.boldSystemFont(ofSize: size)
}

// MARK: 网络请求Key
let NET_REQUEST_SECRET_KEY: String = "H83PGgg8$zbdZ1M9DABF96zqcF1u7i."

// MARK: CDN前缀
let CDN_PREFFIX: String = "https://cdn.conhor.pro"
