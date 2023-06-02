//
//  LRWebCustomNavView.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/10/20.
//

import UIKit

class LRWebCustomNavView: UIView {

    // 定义代理
    weak open var navigationDelegate: HSCustomWebNavigationProtocol?
    
    open var title: String? {
        didSet {
            if let _t = title {
                self.titleLab.text = _t
            }
        }
    }
    
    private lazy var backBtn: UIButton = {
        let goBackBtn = UIButton(type: .custom)
        goBackBtn.setImage(UIImage(named: "more_icon_whiteback"), for: .normal)
        goBackBtn.setImage(UIImage(named: "more_icon_whiteback"), for: .highlighted)
        goBackBtn.addTarget(self, action: #selector(clickGoBackBtn(sender:)), for: .touchUpInside)
        goBackBtn.imageEdgeInsets = UIEdgeInsets.init(top: 3, left: 3, bottom: 3, right: 3)
        goBackBtn.contentMode = .left
        return goBackBtn
    }()
    
    private lazy var refreshBtn: UIButton = {
        let refreshBtn = UIButton(type: .custom)
        refreshBtn.setImage(UIImage(named: "tip_refresh"), for: .normal)
        refreshBtn.setImage(UIImage(named: "tip_refresh"), for: .highlighted)
        refreshBtn.addTarget(self, action: #selector(clickRefreshBtn(sender:)), for: .touchUpInside)
        refreshBtn.alpha = 0
        return refreshBtn
    }()
    
    private lazy var titleLab: UILabel = {
        let lab = UILabel.init()
        lab.textColor = .white
        lab.font = UIFont.boldSystemFont(ofSize: 17)
        lab.textAlignment = .center
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isHidden = true
        self.backgroundColor = .white
        self.addSubview(backBtn)
        self.addSubview(titleLab)
        self.addSubview(refreshBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 64, height: 30))
        }
        
        refreshBtn.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn)
            make.right.equalToSuperview().offset(-15)
            make.size.equalTo(25)
        }
        
        titleLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backBtn)
            make.size.equalTo(CGSize.init(width: UIScreen.main.bounds.width - 150, height: 30))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public methods
    public func hideNav() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
    
    public func showRefreshBtn() {
        UIView.animate(withDuration: 0.3) {
            self.refreshBtn.alpha = 1
        }
    }
    
    public func hideRefreshBtn() {
        UIView.animate(withDuration: 0.3) {
            self.refreshBtn.alpha = 0
        }
    }
}

// MARK: Target
private extension LRWebCustomNavView {
    @objc func clickGoBackBtn(sender: UIButton) {
        navigationDelegate?.hs_webGoBack()
    }
    
    @objc func clickRefreshBtn(sender: UIButton) {
        navigationDelegate?.hs_webRefresh()
    }
}
