//
//  LRChatBootCustomNavView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/26.
//

import UIKit
import Kingfisher

protocol CustomNavProtocol: AnyObject {
    /// 点击订阅
    func AI_goToSubscribePage()
    /// 点击操作
    func AI_clickNavOperation()
}

extension CustomNavProtocol {
    /// 点击订阅
    func AI_goToSubscribePage() {
        
    }
    /// 点击操作
    func AI_clickNavOperation() {
        
    }
}

class LRChatBootCustomNavView: UIView {
    
    weak open var navDelegate: CustomNavProtocol?
    
    /// 是否可以编辑(仅在历史记录模块有效)
    open var canEdit: Bool = false {
        didSet {
            if _type != .History {
                return
            }
            self.userBtn.isHidden = !canEdit
        }
    }
    
    enum CustomNavigationType: CaseIterable {
        case Home
        case Explore
        case History
        
        func getTitle() -> String {
            switch self {
            case .Home:
                return LRLocalizableManager.localValue("homeTitle")
            case .Explore:
                return LRLocalizableManager.localValue("exploreTitle")
            case .History:
                return LRLocalizableManager.localValue("historyTitle")
            }
        }
    }

    private lazy var titleLab: UILabel = {
        let lab = UILabel.init(frame: CGRectZero)
        lab.font = APPFont(20)
        lab.textColor = WhiteColor
        return lab
    }()
    
    private lazy var vipImgView: AnimatedImageView = {
        let animationView = AnimatedImageView()
        animationView.autoPlayAnimatedImage = false
        return animationView
    }()
    
    private lazy var userBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setImage(UIImage(named: "home_icon_setting"), for: UIControl.State.normal)
        btn.setImage(UIImage(named: "home_icon_setting"), for: UIControl.State.highlighted)
        return btn
    }()
    
    private var _type: CustomNavigationType = .Home
    
    init(frame: CGRect, navStyle: CustomNavigationType) {
        super.init(frame: frame)
        self._type = navStyle
        loadNavViews()
        layoutNavViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    func resumeAnimation() {
        self.vipImgView.startAnimating()
    }
    
    func pauseAnimation() {
        self.vipImgView.stopAnimating()
    }
}

// MARK: Private Methods
private extension LRChatBootCustomNavView {
    func loadNavViews() {
        
        self.titleLab.text = _type.getTitle()
        
        self.addSubview(self.titleLab)
        if _type != .History, let _path = LRBundleResourceBase.getFilePath(resourceName: "subscribe", resourceType: "gif", resourceDirectory: "Gif") {
            let _fileURL = NSURL.init(fileURLWithPath: _path) as URL
            self.vipImgView.isUserInteractionEnabled = true
            self.vipImgView.kf.setImage(with: LocalFileImageDataProvider(fileURL: _fileURL, cacheKey: "VIPSubscribe"))
            self.vipImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickSubscribe)))
            self.addSubview(self.vipImgView)
        }
        
        if _type == .History {
            self.userBtn.isHidden = true
            self.userBtn.setImage(UIImage(named: "history_icon_edit"), for: UIControl.State.normal)
            self.userBtn.setImage(UIImage(named: "history_icon_edit"), for: UIControl.State.highlighted)
        }
        
        self.userBtn.addTarget(self, action: #selector(clickOperation(sender: )), for: UIControl.Event.touchUpInside)
        self.addSubview(self.userBtn)
    }
    
    func layoutNavViews() {
        self.titleLab.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(20)
            make.left.equalToSuperview().offset(15)
        }
        
        self.userBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(self.titleLab)
        }
        
        if _type != .History {
            self.vipImgView.snp.makeConstraints { make in
                make.centerY.equalTo(self.titleLab)
                make.right.equalTo(self.userBtn.snp.left).offset(-12)
                make.size.equalTo(30)
            }
        }
    }
}

// MARK: Target
@objc private extension LRChatBootCustomNavView {
    func clickSubscribe() {
        self.navDelegate?.AI_goToSubscribePage()
    }
    
    func clickOperation(sender: UIButton) {
        self.navDelegate?.AI_clickNavOperation()
    }
}
