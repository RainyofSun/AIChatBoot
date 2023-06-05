//
//  LRChatBootSubscribeViewController.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/26.
//

import UIKit
import Toast_Swift
import SwiftyStoreKit

class LRChatBootSubscribeViewController: UIViewController, HideNavigationBarProtocol {

    weak open var subscribePageDelegate: AIIAPSubscribeProtocol?
    /// 是否展示激励弹窗
    open var showRewardVideo: Bool = true
    
    private lazy var subscribeView: LRChatBootSubscribeView = {
        return LRChatBootSubscribeView(frame: CGRectZero)
    }()
    
    /// 是否发起了购买
    private var _iapBuying: Bool = false
    /// 是否发起了恢复购买
    private var _iapRestoring: Bool = false
    // 默认无试用
    private var _subscribeID: String = AppleWeekNoTrialIdentifier
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSubscribeViews()
        layoutSubscribeViews()
        delay(1) {
            self.subscribeView.enableButton()
        }
    }
    
    deinit {
        deallocPrint()
    }
}

// MARK: Private Methods
private extension LRChatBootSubscribeViewController {
    func loadSubscribeViews() {
        self.view.backgroundColor = MainBGColor
        
        self.subscribeView.subscribeDelegate = self
        LRIAPStoreManager.shared.iapDelegate = self
        
        self.view.addSubview(self.subscribeView)
    }
    
    func layoutSubscribeViews() {
        self.subscribeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func subscribeDismiss(completion: (() -> ())? = nil) {
        self.subscribePageDelegate?.AI_subscribePageDidDismiss(false)
        self.navigationController?.dismiss(animated: true, completion: completion)
    }
}

// MARK: AISubcribeProtocol
extension LRChatBootSubscribeViewController: AISubcribeProtocol {
    func AI_closeSubscribePage() {
        if !showRewardVideo {
            // 不需要展示激励弹窗
            self.subscribeDismiss()
            return
        }
        
        // 如果已经发起了购买或者恢复购买,直接关闭,不必弹出广告
        if _iapBuying || _iapRestoring {
            self.subscribeDismiss()
            return
        }
        
        let isExpired = LRIAPStoreManager.shared.localVerificationSubscriptionExpirationTime()
        if !isExpired {
            self.subscribeDismiss();
            return
        }
        
        guard LRRewardADManager.shared.rewardedAd != nil else {
            // 广告没有加载好,不弹窗
            self.subscribeDismiss()
            return
        }
        
        // TODO 展示激励视频广告
    }
    
    func AI_showPrivacyAndService(url: String) {
        let WebVC: LRWebViewController = LRWebViewController()
        WebVC.webLinkUrl = url
        WebVC.webExtraInfo = ["showTitle": true, "hideCustomNav": true]
        self.navigationController?.pushViewController(WebVC, animated: true)
    }
    
    func AI_restoreSubscribe() {
        if LRNetStateManager.shared.netState == .NoNet {
            self.view.makeToast(LRLocalizableManager.localValue("badNet"), duration: 2, position: .center)
            self.subscribeView.removeAnimation()
            self.subscribeView.enableButton()
            return
        }
//        self.view.showLoadingAnimation()
        LRIAPStoreManager.shared.restoreIAPPurchase()
    }
    
    func AI_selectedSubscribeType(isWeekSubscribe: Bool, hasTrial: Bool) {
        _subscribeID = hasTrial ? AppleWeekTrialIdentifier : AppleWeekNoTrialIdentifier
    }
    
    func AI_initiateSubscribe() {
        if LRNetStateManager.shared.netState == .NoNet {
            self.view.makeToast(LRLocalizableManager.localValue("badNet"), duration: 2, position: .center)
            self.subscribeView.removeAnimation()
            self.subscribeView.enableButton()
            return
        }
//        self.view.showLoadingAnimation()
        // 统计
        LRAppsFlyerStatistics.shared.customEventStatistics(SubscribeButtonClickCount)
        LRIAPStoreManager.shared.subscribeTranslateService(productID: _subscribeID)
    }
}

// MARK: HSIAPStoreProtocol
extension LRChatBootSubscribeViewController: HSIAPStoreProtocol {
    func hs_iapPurchaseStart() {
        _iapBuying = true
    }
    
    func hs_iapRestoreStart() {
        _iapRestoring = true
    }
    
    func hs_iapRestoreEnd() {
        _iapRestoring = false
        self.subscribeView.removeAnimation()
//        self.view.hideLoadingAnimation()
        self.view.makeToast(LRLocalizableManager.localValue("noRestore"))
    }
    
    func hs_iapVerifyReceiptSuccess(receiptItem: ReceiptItem) {
        _iapBuying = false
        self.subscribeView.removeAnimation()
//        self.view.hideLoadingAnimation()
        subscribeView.enableButton()
        self.view.makeToast(LRLocalizableManager.localValue("subscribeSuccess"))
        self.subscribeDismiss {
            self.subscribePageDelegate?.AI_iapSubscributeSuccess()
        }
    }
    
    func hs_iapPurchaseFailture(error: IAPPurchaseError) {
        _iapBuying = false
        self.subscribeView.removeAnimation()
//        self.view.hideLoadingAnimation()
        self.view.makeToast(LRLocalizableManager.localValue("failPurchase"), duration: 2, position: .center)
        subscribeView.enableButton()
    }
    
    func hs_iapRestoreSuccess(product: Purchase) {
        _iapRestoring = false
        self.subscribeView.removeAnimation()
//        self.view.hideLoadingAnimation()
        subscribeView.enableButton()
        if let iapInfo = LRIAPCache.getIAPPurchase(), iapInfo.subcributeIsExpire {
            Log.debug("<<<<<<<< 恢复订阅成功,但是订阅已经过期 >>>>>>>>>>>")
            self.view.makeToast(LRLocalizableManager.localValue("subscribeExpiredRestore"), duration: 2, position: .center)
            return
        }
        self.view.makeToast(LRLocalizableManager.localValue("successRestore"), duration: 2, position: .center)
        self.subscribeDismiss {
            self.subscribePageDelegate?.AI_iapSubscributeRestoreSuccess()
        }
    }
    
    func hs_iapRestoreFaile(error: IAPPurchaseError) {
        _iapRestoring = false
        self.subscribeView.removeAnimation()
//        self.view.hideLoadingAnimation()
        subscribeView.enableButton()
        self.view.makeToast(LRLocalizableManager.localValue("failRestore"), duration: 2, position: .center)
    }
}
