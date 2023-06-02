//
//  LRChatBootRateAlert.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/28.
//

import UIKit

class LRChatBootRateAlert: LRChatBootAlertView {

    private lazy var rateView: LRStarRateView = {
        let view = LRStarRateView(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 243, height: 44)), bottomStar: "review_icon_startGray", topStar: "review_icon_startYellow")
        view.userPanEnabled = true
        view.currentStarCount = 5.0
        return view
    }()
    
    override func setAlertTitle(title: String, alertSubTitle subT: String = "", alertImage image: String, okButtonTitle okTitle: String? = nil) {
        self.alertImageView.image = UIImage(named: image)
        self.alertTitleLab.text = title
        self.alertTitleLab.font = APPFont(19)
        self.alertTitleLab.textColor = TextMainColor
        self.alertOKBtn.setTitle(okTitle, for: UIControl.State.normal)
        self.alertOKBtn.setTitle(okTitle, for: UIControl.State.highlighted)
    }

    override func hookMethods() {
        super.hookMethods()
        self.alertBgView.addSubview(self.rateView)
        self.rateView.snp.makeConstraints { make in
            make.bottom.equalTo(self.alertOKBtn.snp.top).offset(-40)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 243, height: 44))
        }
        
        self.alertTitleLab.snp.remakeConstraints { make in
            make.bottom.equalTo(self.rateView.snp.top).offset(-20)
            make.horizontalEdges.equalToSuperview().inset(15)
            make.top.equalTo(self.alertImageView.snp.bottom).offset(70)
        }
    }
    
    // MARK: Public Methods
    public func getRate() -> Float {
        return rateView.currentStarCount
    }
}
