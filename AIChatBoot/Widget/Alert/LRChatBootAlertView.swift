//
//  LRChatBootAlertView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/28.
//

import UIKit

class LRChatBootAlertView: UIView {
    
    private(set) lazy var alertBgView: UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = WhiteColor
        view.cornerRadius = 20
        return view
    }()
    
    private(set) lazy var alertImageView: UIImageView = {
        return UIImageView(frame: CGRectZero)
    }()
    
    private(set) lazy var alertTitleLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.numberOfLines = .zero
        return lab
    }()
    
    private lazy var alertCancelBtn: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setTitle(LRLocalizableManager.localValue("Cancel"), for: UIControl.State.normal)
        button.setTitle(LRLocalizableManager.localValue("Cancel"), for: UIControl.State.highlighted)
        button.setTitleColor(UIColor(hexString: "#aaaaaa"), for: UIControl.State.normal)
        button.setTitleColor(UIColor(hexString: "#aaaaaa"), for: UIControl.State.highlighted)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.cornerRadius = 22
        button.backgroundColor = UIColor.init(hexString: "#EEEEEE")
        return button
    }()
    
    private(set) lazy var alertOKBtn: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setTitle(LRLocalizableManager.localValue("Delete"), for: UIControl.State.normal)
        button.setTitle(LRLocalizableManager.localValue("Delete"), for: UIControl.State.highlighted)
        button.setTitleColor(WhiteColor, for: UIControl.State.normal)
        button.setTitleColor(WhiteColor, for: UIControl.State.highlighted)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.cornerRadius = 22
        button.backgroundColor = APPThemeColor
        return button
    }()
    
    private var handler: ((Bool)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadAlertViews()
        layoutAlertViews()
        hookMethods()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }

    // MARK: Public Methods
    public func setAlertTitle(title: String, alertSubTitle subT: String = "", alertImage image: String, okButtonTitle okTitle: String? = nil) {
        self.alertTitleLab.attributedText = attributeTitle(title: title, subT: subT)
        self.alertImageView.image = UIImage(named: image)
        self.alertTitleLab.sizeToFit()
        
        if okTitle != nil {
            self.alertOKBtn.setTitle(okTitle, for: UIControl.State.normal)
            self.alertOKBtn.setTitle(okTitle, for: UIControl.State.highlighted)
        }
    }
    
    public func showAlert(completeHandler: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: APPAnimationDurationTime) {
            self.alpha = 1
            self.alertBgView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: APPAnimationDurationTime) {
                self.alertBgView.transform = .identity
            }
            self.handler = completeHandler
        }
    }
    
    // MARK: Hook Methods
    public func hookMethods() {
        
    }
}

// MARK: Private Methods
private extension LRChatBootAlertView {
    func loadAlertViews() {
        self.alpha = .zero
        self.backgroundColor = UIColor(white: .zero, alpha: 0.3)
        
        self.alertCancelBtn.addTarget(self, action: #selector(clickCancelButton(sender: )), for: UIControl.Event.touchUpInside)
        self.alertOKBtn.addTarget(self, action: #selector(clickOKButton(sender: )), for: UIControl.Event.touchUpInside)
        
        self.addSubview(self.alertBgView)
        self.alertBgView.addSubview(self.alertImageView)
        self.alertBgView.addSubview(self.alertTitleLab)
        self.alertBgView.addSubview(self.alertCancelBtn)
        self.alertBgView.addSubview(self.alertOKBtn)
    }
    
    func layoutAlertViews() {
        self.alertBgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(295)
        }
        
        self.alertImageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(20)
            make.size.equalTo(100)
        }
        
        self.alertCancelBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(44)
        }
        
        self.alertOKBtn.snp.makeConstraints { make in
            make.left.equalTo(self.alertCancelBtn.snp.right).offset(10)
            make.right.equalToSuperview().offset(-15)
            make.centerY.size.equalTo(self.alertCancelBtn)
        }
        
        self.alertTitleLab.snp.makeConstraints { make in
            make.top.equalTo(self.alertImageView.snp.bottom).offset(70)
            make.horizontalEdges.equalToSuperview().inset(15)
            make.bottom.equalTo(self.alertCancelBtn.snp.top).offset(-40)
        }
    }
    
    func attributeTitle(title: String, subT: String) -> NSAttributedString {
        let paraStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paraStyle.paragraphSpacing = 20
        let attributeTitle: NSMutableAttributedString = NSMutableAttributedString(string: (title + "\n" + subT), attributes: [.font: APPFont(19), .foregroundColor: TextMainColor, .paragraphStyle: paraStyle])
        attributeTitle.addAttributes([.foregroundColor: TextMainColor, .font: UIFont(name: "Arial", size: 15) ?? UIFont.systemFont(ofSize: 15), .paragraphStyle: paraStyle], range: NSRange(location: title.count, length: subT.count + 1))
        return attributeTitle
    }
}

// MARK: Target
@objc private extension LRChatBootAlertView {
    func clickCancelButton(sender: UIButton) {
        UIView.animate(withDuration: APPAnimationDurationTime) {
            self.alpha = .zero
        } completion: { _ in
            self.removeFromSuperview()
            self.handler?((sender == self.alertOKBtn))
        }
    }
    
    func clickOKButton(sender: UIButton) {
        clickCancelButton(sender: sender)
    }
}
