//
//  LRChatBootSubscribeView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/5.
//

import UIKit

class LRChatBootSubscribeView: UIView {

    weak open var subscribeDelegate: AISubcribeProtocol?
    
    private lazy var closeBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setImage(UIImage(named: "subscribe_icon_close"), for: UIControl.State.normal)
        btn.setImage(UIImage(named: "subscribe_icon_close"), for: UIControl.State.highlighted)
        return btn
    }()

    private lazy var titleLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.text = LRLocalizableManager.localValue("subscribeTitle")
        lab.textAlignment = .center
        lab.font = APPFont(35)
        lab.textColor = UIColor(hexString: "#FFED66")
        lab.numberOfLines = .zero
        return lab
    }()

    private lazy var wordLimitItem: LRChatBootSubscribeItem = {
        let item = LRChatBootSubscribeItem(frame: CGRectZero)
        item.setSubscribeTitle(LRLocalizableManager.localValue("subscribeItem1"), subscribeSubTitle: LRLocalizableManager.localValue("subscribeItem1Sub"), subscribeImage: "subscribe_icon_wordLimit")
        return item
    }()
    
    private lazy var limitItem: LRChatBootSubscribeItem = {
        let item = LRChatBootSubscribeItem(frame: CGRectZero)
        item.setSubscribeTitle(LRLocalizableManager.localValue("subscribeItem2"), subscribeSubTitle: LRLocalizableManager.localValue("subscribeItem2Sub"), subscribeImage: "subscribe_icon_wordLimit")
        return item
    }()
    
    private lazy var adItem: LRChatBootSubscribeItem = {
        let item = LRChatBootSubscribeItem(frame: CGRectZero)
        item.setSubscribeTitle(LRLocalizableManager.localValue("subscribeItem3"), subscribeSubTitle: LRLocalizableManager.localValue("subscribeItem3Sub"), subscribeImage: "subscribe_icon_ad")
        return item
    }()
    
    private lazy var weekPriceControl: LRChatBootSubscribeButton = {
        return LRChatBootSubscribeButton(frame: CGRectZero)
    }()
    
    private lazy var tipLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.text = LRLocalizableManager.localValue("subscribeTip")
        lab.textAlignment = .center
        lab.font = UIFont.boldSystemFont(ofSize: 15)
        lab.textColor = APPThemeColor
        return lab
    }()
    
    private lazy var continueBtn: LRChatBootAILoadingButton = {
        let btn = LRChatBootAILoadingButton(type: UIButton.ButtonType.custom)
        btn.setTitle(LRLocalizableManager.localValue("subscribeContinue"), for: UIControl.State.normal)
        btn.setTitle(LRLocalizableManager.localValue("subscribeContinue"), for: UIControl.State.highlighted)
        btn.setTitleColor(WhiteColor, for: UIControl.State.normal)
        btn.setTitleColor(WhiteColor, for: UIControl.State.highlighted)
        btn.titleLabel?.font = APPFont(23)
        btn.cornerRadius = 35
        btn.backgroundColor = APPThemeColor
        return btn
    }()

    private lazy var serviceBtn1: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setTitle(LRLocalizableManager.localValue("subscribeService1"), for: UIControl.State.normal)
        btn.setTitle(LRLocalizableManager.localValue("subscribeService1"), for: UIControl.State.highlighted)
        btn.setTitleColor(WhiteColor.withAlphaComponent(0.8), for: UIControl.State.normal)
        btn.setTitleColor(WhiteColor.withAlphaComponent(0.8), for: UIControl.State.highlighted)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        return btn
    }()
    
    private lazy var serviceBtn2: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setTitle(LRLocalizableManager.localValue("subscribeService2"), for: UIControl.State.normal)
        btn.setTitle(LRLocalizableManager.localValue("subscribeService2"), for: UIControl.State.highlighted)
        btn.setTitleColor(WhiteColor.withAlphaComponent(0.8), for: UIControl.State.normal)
        btn.setTitleColor(WhiteColor.withAlphaComponent(0.8), for: UIControl.State.highlighted)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        return btn
    }()
    
    private lazy var restoreBtn: LRChatBootAILoadingButton = {
        let btn = LRChatBootAILoadingButton(type: UIButton.ButtonType.custom)
        btn.setTitle(LRLocalizableManager.localValue("subscribeRestore"), for: UIControl.State.normal)
        btn.setTitle(LRLocalizableManager.localValue("subscribeRestore"), for: UIControl.State.highlighted)
        btn.setTitleColor(WhiteColor.withAlphaComponent(0.8), for: UIControl.State.normal)
        btn.setTitleColor(WhiteColor.withAlphaComponent(0.8), for: UIControl.State.highlighted)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        return btn
    }()
    
    private lazy var line1: UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor(hexString: "#D8D8D8")
        return view
    }()
    
    private lazy var line2: UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor(hexString: "#D8D8D8")
        return view
    }()
    
    private lazy var tipTextView: UITextView = {
        let label = UITextView.init()
        label.text = LRLocalizableManager.localValue("subscribeNote")
        label.textColor = WhiteColor.withAlphaComponent(0.8)
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.showsVerticalScrollIndicator = false
        label.backgroundColor = .clear
        label.textContainer.lineBreakMode = .byCharWrapping
        label.textAlignment = .justified
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadSubscribeViews()
        layoutSubscribeViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    /// 禁用订阅按钮、恢复订阅按钮
    public func disableButton() {
        self.restoreBtn.isEnabled = false
        self.continueBtn.isEnabled = false
    }
    
    /// 启用订阅按钮、恢复订阅按钮
    public func enableButton() {
        restoreBtn.isEnabled = true
        continueBtn.isEnabled = true
    }
    
    /// 移除所有按钮loading动画
    public func removeAnimation() {
        restoreBtn.stopAnimation()
        continueBtn.stopAnimation()
    }
    
    /// 更新订阅价格
    public func updateSubscribePrice(weekPrice: String) {
        self.weekPriceControl.updatePrice(price: weekPrice)
    }
}

// MARK: Private Methods
private extension LRChatBootSubscribeView {
    func loadSubscribeViews() {
        
        self.closeBtn.addTarget(self, action: #selector(clickCloseBtn(sender: )), for: UIControl.Event.touchUpInside)
        self.continueBtn.addTarget(self, action: #selector(clickContinueBtn(sender: )), for: UIControl.Event.touchUpInside)
        self.serviceBtn1.addTarget(self, action: #selector(clickService1Btn(sender: )), for: UIControl.Event.touchUpInside)
        self.serviceBtn2.addTarget(self, action: #selector(clickService2Btn(sender: )), for: UIControl.Event.touchUpInside)
        self.restoreBtn.addTarget(self, action: #selector(clickRestoreBtn(sender: )), for: UIControl.Event.touchUpInside)
        
        self.tipTextView.delegate = self
        
        self.addSubview(self.closeBtn)
        self.addSubview(self.titleLab)
        self.addSubview(self.wordLimitItem)
        self.addSubview(self.limitItem)
        self.addSubview(self.adItem)
        self.addSubview(self.weekPriceControl)
        self.addSubview(self.tipLab)
        self.addSubview(self.continueBtn)
        self.addSubview(self.serviceBtn1)
        self.addSubview(self.line1)
        self.addSubview(self.serviceBtn2)
        self.addSubview(self.line2)
        self.addSubview(self.restoreBtn)
        self.addSubview(self.tipTextView)
        disableButton()
    }
    
    func layoutSubscribeViews() {
        self.closeBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(40)
            make.size.equalTo(40)
        }
        
        self.titleLab.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(22)
            make.top.equalTo(self.closeBtn.snp.bottom).offset(5)
        }
        
        self.wordLimitItem.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalToSuperview()
            make.top.equalTo(self.titleLab.snp.bottom).offset(30)
        }

        self.limitItem.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(self.wordLimitItem)
            make.top.equalTo(self.wordLimitItem.snp.bottom).offset(5)
        }

        self.adItem.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(self.wordLimitItem)
            make.top.equalTo(self.limitItem.snp.bottom).offset(5)
        }

        self.weekPriceControl.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(15)
            make.top.equalTo(self.adItem.snp.bottom).offset(35)
        }

        self.tipLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.weekPriceControl.snp.bottom).offset(20)
        }

        self.continueBtn.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(15)
            make.top.equalTo(self.tipLab.snp.bottom).offset(15)
            make.height.equalTo(70)
        }

        self.serviceBtn1.snp.makeConstraints { make in
            make.left.equalTo(self.continueBtn.snp.left).offset(50)
            make.top.equalTo(self.continueBtn.snp.bottom).offset(30)
        }

        self.line1.snp.makeConstraints { make in
            make.centerY.equalTo(self.serviceBtn1)
            make.left.equalTo(self.serviceBtn1.snp.right).offset(10)
            make.width.equalTo(1)
            make.height.equalTo(self.serviceBtn1).multipliedBy(0.4)
        }

        self.serviceBtn2.snp.makeConstraints { make in
            make.centerY.equalTo(self.serviceBtn1)
            make.left.equalTo(self.line1.snp.right).offset(10)
        }

        self.line2.snp.makeConstraints { make in
            make.centerY.size.equalTo(self.line1)
            make.left.equalTo(self.serviceBtn2.snp.right).offset(10)
        }

        self.restoreBtn.snp.makeConstraints { make in
            make.centerY.equalTo(self.line2)
            make.left.equalTo(self.line2.snp.right).offset(10)
        }

        self.tipTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(15)
            make.top.equalTo(self.serviceBtn1.snp.bottom).offset(5)
            make.height.equalTo(UIWindow.safeAreaBottom() == .zero ? 60 : 85)
        }
    }
}

// MARK: UITextViewDelegate
extension LRChatBootSubscribeView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
}

// MARK: Target
@objc private extension LRChatBootSubscribeView {
    func clickCloseBtn(sender: UIButton) {
        self.subscribeDelegate?.AI_closeSubscribePage()
    }
    
    func clickContinueBtn(sender: LRChatBootAILoadingButton) {
        disableButton()
        sender.startAnimation()
        self.subscribeDelegate?.AI_selectedSubscribeType(isWeekSubscribe: true, hasTrial: true)
        self.subscribeDelegate?.AI_initiateSubscribe()
    }
    
    func clickRestoreBtn(sender: LRChatBootAILoadingButton) {
        disableButton()
        sender.startAnimation()
        self.subscribeDelegate?.AI_restoreSubscribe()
    }
    
    func clickService1Btn(sender: UIButton) {
        self.subscribeDelegate?.AI_showPrivacyAndService(url: APPPrivacy)
    }
    
    func clickService2Btn(sender: UIButton) {
        self.subscribeDelegate?.AI_showPrivacyAndService(url: APPService)
    }
}
