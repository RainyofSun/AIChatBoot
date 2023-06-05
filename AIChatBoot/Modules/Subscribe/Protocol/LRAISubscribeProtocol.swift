//
//  LRAISubscribeProtocol.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/14.
//

import UIKit

// MARK: Protocol
/// 订阅代理
protocol AISubcribeProtocol: AnyObject {
    /// 关闭订阅页面
    func AI_closeSubscribePage()
    /// 恢复订阅
    func AI_restoreSubscribe()
    /// 订阅
    func AI_selectedSubscribeType(isWeekSubscribe: Bool, hasTrial: Bool)
    /// 发起订阅
    func AI_initiateSubscribe()
    /// 点击协议
    func AI_showPrivacyAndService(url: String)
}

/// IAP订阅结果回调
protocol AIIAPSubscribeProtocol: AnyObject {
    /// 订阅页面消失
    func AI_subscribePageDidDismiss(_ watchedJiLiAD:Bool)
    /// 订阅成功
    func AI_iapSubscributeSuccess()
    /// 恢复订阅成功
    func AI_iapSubscributeRestoreSuccess()
}

extension AIIAPSubscribeProtocol {
    /// 订阅页面消失
    func AI_subscribePageDidDismiss(_ watchedJiLiAD:Bool) {
        Log.debug("订阅 默认实现")
    }
    /// 订阅成功
    func AI_iapSubscributeSuccess() {
        Log.debug("订阅 默认实现")
    }
    /// 恢复订阅成功
    func AI_iapSubscributeRestoreSuccess() {
        Log.debug("订阅 默认实现")
    }
}
