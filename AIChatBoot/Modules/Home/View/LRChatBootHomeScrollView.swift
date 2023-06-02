//
//  LRChatBootHomeScrollView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/28.
//

import UIKit

class LRChatBootHomeScrollView: UIScrollView {

    open weak var topicDelegate: ChatBootTopicCellProtocol? {
        didSet {
            self.recommendTopicView.topicDelegate = topicDelegate
            self.likeTopicView.topicDelegate = topicDelegate
            self.hotTopicView.topicDelegate = topicDelegate
        }
    }
    
    private(set) lazy var recommendTopicView: LRChatBootTopicRecommendationView = {
        return LRChatBootTopicRecommendationView(frame: CGRectZero)
    }()
    
    private(set) lazy var likeTopicView: LRChatBootLikeTopicView = {
        return LRChatBootLikeTopicView(frame: CGRectZero)
    }()
    
    private(set) lazy var hotTopicView: LRChatBootHotTopicView = {
        return LRChatBootHotTopicView(frame: CGRectZero)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadScrollSubviews()
        layoutScrollSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
}

// MARK: Private Methods
private extension LRChatBootHomeScrollView {
    func loadScrollSubviews() {
        self.backgroundColor = .clear
        self.alwaysBounceVertical = true
        
        self.addSubview(self.recommendTopicView)
        self.addSubview(self.likeTopicView)
        self.addSubview(self.hotTopicView)
    }
    
    func layoutScrollSubviews() {
        self.recommendTopicView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(UIScreen.main.bounds.width - 20)
        }
        
        self.likeTopicView.snp.makeConstraints { make in
            make.top.equalTo(self.recommendTopicView.snp.bottom).offset(10)
            make.width.left.equalTo(self.recommendTopicView)
        }
        
        self.hotTopicView.snp.makeConstraints { make in
            make.top.equalTo(self.likeTopicView.snp.bottom).offset(10)
            make.width.left.equalTo(self.recommendTopicView)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}
