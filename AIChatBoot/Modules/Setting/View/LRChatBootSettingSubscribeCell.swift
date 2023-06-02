//
//  LRChatBootSettingSubscribeCell.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/31.
//

import UIKit

class LRChatBootSettingSubscribeCell: UITableViewCell {

    private lazy var bgView: UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor(hexString: "#0A1466")
        view.cornerRadius = 20
        return view
    }()
    
    private lazy var titleLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.numberOfLines = .zero
        return lab
    }()
    
    private lazy var vipImageView: UIImageView = {
        return UIImageView(image: UIImage(named: "setting_icon_vip"))
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadSubscribeViews()
        layoutSubscribeViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
}

// MARK: Private Methods
private extension LRChatBootSettingSubscribeCell {
    func loadSubscribeViews() {
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        let paraStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paraStyle.paragraphSpacing = 8
        let _title: String = LRLocalizableManager.localValue("settingVIPTitle")
        let _content: String = LRLocalizableManager.localValue("settingVIPContent")
        let attributeStr: NSMutableAttributedString = NSMutableAttributedString(string: (_title + "\n" + _content), attributes: [.font: APPFont(20), .foregroundColor: WhiteColor, .paragraphStyle: paraStyle])
        attributeStr.addAttributes([.font: UIFont.systemFont(ofSize: 13), .foregroundColor: WhiteColor, .paragraphStyle: paraStyle], range: NSRange(location: _title.count, length: (_content.count + 1)))
        self.titleLab.attributedText = attributeStr
        
        self.contentView.addSubview(self.bgView)
        self.bgView.addSubview(self.vipImageView)
        self.bgView.addSubview(self.titleLab)
    }
    
    func layoutSubscribeViews() {
        self.bgView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(5)
        }
        
        self.titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.verticalEdges.equalToSuperview().inset(15)
        }
        
        self.vipImageView.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
        }
    }
}
