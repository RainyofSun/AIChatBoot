//
//  LRChatBootExploreClassifyCell.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/30.
//

import UIKit
import Kingfisher

class LRChatBootExploreClassifyCell: UICollectionViewCell {
    
    private lazy var classifyImageView: UIImageView = {
        return UIImageView(frame: CGRectZero)
    }()
    
    private lazy var contentLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.numberOfLines = .zero
        lab.font = UIFont.boldSystemFont(ofSize: 14)
        lab.textColor = UIColor(hexString: "#CCCCCC")
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadClassifyCellViews()
        layoutClassifyCellViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func reloadCellSource(model: LRChatBootTopicModel) {
        if let _url = model.topicImageURL {
            self.classifyImageView.kf.setImage(with: ImageResource(downloadURL: URL.init(string: _url)!), options: [.transition(.fade(APPAnimationDurationTime)), .backgroundDecode, .memoryCacheExpiration(.expired), .scaleFactor(UIScreen.main.scale)])
        }
        
        if let _content = model.topic {
            self.contentLab.text = _content
        }
    }
}

// MARK: Private Methods
private extension LRChatBootExploreClassifyCell {
    func loadClassifyCellViews() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = UIColor(hexString: "#1A1A1A")
        self.classifyImageView.backgroundColor = UIColor.cyan.withAlphaComponent(0.4)
        self.cornerRadius = 20
        self.contentView.addSubview(self.classifyImageView)
        self.contentView.addSubview(self.contentLab)
    }
    
    func layoutClassifyCellViews() {
        self.classifyImageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(10)
            make.size.equalTo(40)
        }
        
        self.contentLab.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(8)
            make.top.equalTo(self.classifyImageView.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-13)
        }
    }
}
