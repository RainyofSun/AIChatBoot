//
//  LRChatBootHotTopicCell.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit
import Kingfisher

class LRChatBootHotTopicCell: UITableViewCell {
    
    weak open var cellDelegate: ChatBootTopicCellProtocol?
    
    private lazy var tagBtn: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.backgroundColor = UIColor(white: .zero, alpha: 0.1)
        button.setTitleColor(WhiteColor, for: UIControl.State.normal)
        button.setTitleColor(WhiteColor, for: UIControl.State.highlighted)
        button.cornerRadius = 14
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        return button
    }()
    
    private(set) lazy var hotLab: UILabel = {
        return UILabel(frame: CGRectZero)
    }()
    
    private(set) lazy var contentLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.numberOfLines = 2
        lab.textColor = UIColor(hexString: "#222222")
        lab.font = UIFont.boldSystemFont(ofSize: 18)
        return lab
    }()
    
    private lazy var lineImageView: UIImageView = {
        return UIImageView(image: UIImage(named: "home_topic_line"))
    }()
    
    private var _classification_id: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadBannerCellViews()
        layoutBannerCellViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func reloadTopicCellSource(model: LRChatBootTopicModel) {
        if let _c_t = model.topicClassification {
            self._classification_id = model.topicClassificationID
            let _textW = _c_t.textWidth(font: self.tagBtn.titleLabel?.font ?? UIFont.boldSystemFont(ofSize: 13), height: 30) + 20
            self.tagBtn.setTitle(_c_t, for: UIControl.State.normal)
            self.tagBtn.setTitle(_c_t, for: UIControl.State.highlighted)
            self.tagBtn.snp.updateConstraints { make in
                make.width.equalTo(_textW)
            }
        }
        
        if let _num = model.hotTopics {
            self.hotLab.attributedText = attributeHot(hotNum: _num)
        }
        
        if let _c = model.topic {
            self.contentLab.text = _c
        }
    }
}

// MARK: Private Methods
private extension LRChatBootHotTopicCell {
    func loadBannerCellViews() {
        
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.tagBtn.addTarget(self, action: #selector(clickTagButton(sender: )), for: UIControl.Event.touchUpInside)
        
        self.contentView.addSubview(self.tagBtn)
        self.contentView.addSubview(self.hotLab)
        self.contentView.addSubview(self.contentLab)
        self.contentView.addSubview(self.lineImageView)
    }
    
    func layoutBannerCellViews() {
        
        self.tagBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview()
            make.height.equalTo(28)
            make.width.equalTo(90)
        }
        
        self.hotLab.snp.makeConstraints { make in
            make.centerY.equalTo(self.tagBtn)
            make.right.equalToSuperview().offset(-20)
        }
        
        self.contentLab.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(self.tagBtn.snp.bottom).offset(10)
        }
        
        self.lineImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.contentLab.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func attributeHot(hotNum: String) -> NSAttributedString {
        let _image: UIImage = UIImage(named: "home_icon_hot")!
        let attachment: NSTextAttachment = NSTextAttachment(image: _image)
        attachment.bounds = CGRect(x: .zero, y: -2, width: _image.size.width, height: _image.size.height)
        let attributeTitle: NSMutableAttributedString = NSMutableAttributedString(string: " " + hotNum, attributes: [.font: APPFont(17), .foregroundColor: UIColor(hexString: "#E63C6A")])
        attributeTitle.insert(NSAttributedString(attachment: attachment), at: .zero)
        return attributeTitle
    }
}

// MARK: Target
@objc private extension LRChatBootHotTopicCell {
    func clickTagButton(sender: UIButton) {
        self.cellDelegate?.AI_selectedTopicClassification(classificationID: _classification_id)
    }
}
