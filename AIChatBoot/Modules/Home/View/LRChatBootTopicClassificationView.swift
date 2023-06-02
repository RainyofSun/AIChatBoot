//
//  LRChatBootTopicClassificationView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit

class LRChatBootTopicClassificationView: UIView {
    
    open weak var topicDelegate: ChatBootTopicCellProtocol?
    
    private(set) lazy var titleLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.numberOfLines = .zero
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadTopicViews()
        layoutTopicViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func attributeTitle(title: String, imageName: String, imageTopAscend ascend: CGFloat = -5, foregroundColor color: UIColor = .black) -> NSAttributedString {
        let _image: UIImage = UIImage(named: imageName)!
        let attachment: NSTextAttachment = NSTextAttachment(image: _image)
        attachment.bounds = CGRect(x: .zero, y: ascend, width: _image.size.width, height: _image.size.height)
        let attributeTitle: NSMutableAttributedString = NSMutableAttributedString(string: " " + title, attributes: [.font: APPFont(16), .foregroundColor: color])
        attributeTitle.insert(NSAttributedString(attachment: attachment), at: .zero)
        return attributeTitle
    }
    
    /// 更新话题
    public func updateTopics(data: [LRChatBootTopicModel]) {
        
    }
}

// MARK: Subclass Implementation
@objc extension LRChatBootTopicClassificationView {
    func loadTopicViews() {
        self.cornerRadius = 20
        self.addSubview(self.titleLab)
    }
    
    func layoutTopicViews() {
        self.titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
}
