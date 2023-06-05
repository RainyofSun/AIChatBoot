//
//  LRChatBootSubscribeItem.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/5.
//

import UIKit

class LRChatBootSubscribeItem: UIView {

    private lazy var itemImage: UIImageView = {
        return UIImageView(frame: CGRectZero)
    }()
    
    private lazy var titleLab: UILabel = {
        return UILabel(frame: CGRectZero)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadItemViews()
        layoutItemViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func setSubscribeTitle(_ title: String, subscribeSubTitle subT: String, subscribeImage image: String) {
        self.itemImage.image = UIImage(named: image)
        let attributeTitle: NSMutableAttributedString = NSMutableAttributedString(string: (title + "\n" + subT), attributes: [.font: APPFont(19), .foregroundColor: WhiteColor])
        attributeTitle.addAttributes([.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: WhiteColor.withAlphaComponent(0.8)], range: NSRange(location: title.count, length: (subT.count + 1)))
        self.titleLab.attributedText = attributeTitle
    }
}

// MARK: Private Methods
private extension LRChatBootSubscribeItem {
    func loadItemViews() {
        
        titleLab.numberOfLines = .zero
        
        self.addSubview(self.itemImage)
        self.addSubview(self.titleLab)
    }
    
    func layoutItemViews() {
        self.itemImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(70)
            make.centerY.equalTo(self.titleLab)
        }
        
        self.titleLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.itemImage.snp.right).offset(20)
        }
    }
}
