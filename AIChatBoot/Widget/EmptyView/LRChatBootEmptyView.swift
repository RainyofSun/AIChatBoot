//
//  LRChatBootEmptyView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/30.
//

import UIKit

class LRChatBootEmptyView: UIView {

    private lazy var emptyImgView: UIImageView = {
        return UIImageView.init(frame: CGRectZero)
    }()
    
    private lazy var emptyTitleLab: UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor(hexString: "#AAAAAA")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        emptyImgView.contentMode = .scaleAspectFit
        self.addSubview(emptyImgView)
        self.addSubview(emptyTitleLab)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emptyImgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
            make.size.equalTo(CGSize(width: 175, height: 125))
        }
        
        emptyTitleLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyImgView.snp.bottom).offset(6)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    /// 外界设置占位图
    public func placeholderImage(_ img: UIImage, placeholderText: String = "") {
        self.emptyImgView.image = img
        self.emptyTitleLab.text = placeholderText
        
        emptyTitleLab.sizeToFit()
    }

}
