//
//  LRChatBootSettingCell.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/31.
//

import UIKit

class LRChatBootSettingCell: UITableViewCell {

    private lazy var bgView: UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor(hexString: "#1A1A1A")
        view.cornerRadius = 20
        return view
    }()
    
    private lazy var titleLab: UILabel = {
        return UILabel(frame: CGRectZero)
    }()
    
    private lazy var subTitleLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.text = LRCleanDeviceTool.getLocalVersion()
        lab.textColor = UIColor(hexString: "#AAAAAA")
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.isHidden = true
        return lab
    }()
    
    private lazy var arrowImgView: UIImageView = {
        return UIImageView(image: UIImage(named: "setting_icon_arrow"))
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadSettingViews()
        layoutSettingViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func settingCellSource(title: String, settingImage image: String, showArrow: Bool) {
        let _image = UIImage(named: image)!
        let attachment: NSTextAttachment = NSTextAttachment(image: _image)
        attachment.bounds = CGRect(x: .zero, y: -3, width: _image.size.width, height: _image.size.height)
        let attributeStr: NSMutableAttributedString = NSMutableAttributedString(string: (" " + title), attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: WhiteColor])
        attributeStr.insert(NSAttributedString(attachment: attachment), at: .zero)
        self.titleLab.attributedText = attributeStr
        
        self.arrowImgView.isHidden = !showArrow
        self.subTitleLab.isHidden = showArrow
    }
}

// MARK: Public Methods
private extension LRChatBootSettingCell {
    func loadSettingViews() {
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.contentView.addSubview(self.bgView)
        self.bgView.addSubview(self.titleLab)
        self.bgView.addSubview(self.subTitleLab)
        self.bgView.addSubview(self.arrowImgView)
    }
    
    func layoutSettingViews() {
        self.bgView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.horizontalEdges.equalToSuperview()
        }
        
        self.titleLab.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(17)
            make.left.equalToSuperview().offset(20)
        }
        
        self.arrowImgView.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLab)
            make.right.equalToSuperview().offset(-15)
        }
        
        self.subTitleLab.snp.makeConstraints { make in
            make.centerY.right.equalTo(self.arrowImgView)
        }
    }
}
