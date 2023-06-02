//
//  LRChatBootExploreHorizationScrollview.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit

class LRChatBootExploreHorizationScrollview: UIScrollView {
    
    private var classifyViewCache: [Int: UIView] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadHorizationViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func buildTopClassifyView(classifyID: String, classifyViewIndex index: Int, topicDelegate delegate: ChatBootTopicCellProtocol?) {
        if classifyViewCache[index] == nil {
            if index == .zero {
                let allClassifyView = LRChatBootExploreAllClassifyView(frame: CGRectZero)
                self.addSubview(allClassifyView)
                allClassifyView.snp.makeConstraints { make in
                    make.top.left.size.equalToSuperview()
                }
                allClassifyView.topicDelegate = delegate
                classifyViewCache[index] = allClassifyView
            } else {
                let classifyView = LRChatBootExploreClassifyView(frame: CGRectZero)
                self.addSubview(classifyView)
                classifyView.snp.makeConstraints { make in
                    make.top.size.equalToSuperview()
                    make.left.equalToSuperview().offset(self.width * CGFloat(index))
                }
                classifyView.topicDelegate = delegate
                classifyViewCache[index] = classifyView
            }
        }
        self.setContentOffset(CGPoint(x: self.width * CGFloat(index), y: .zero), animated: true)
    }
}

// MARK: Private Methods
private extension LRChatBootExploreHorizationScrollview {
    func loadHorizationViews() {
        self.showsHorizontalScrollIndicator = false
        self.isPagingEnabled = true
        self.isScrollEnabled = false
        self.contentInset = UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 10)
    }
}
