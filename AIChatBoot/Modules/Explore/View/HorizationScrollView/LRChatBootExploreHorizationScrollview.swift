//
//  LRChatBootExploreHorizationScrollview.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit

class LRChatBootExploreHorizationScrollview: UIScrollView {
    
    private var classifyViewCache: [Int: ChatBootExploreDataSourceProtocol] = [:]
    
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
    /// 创建分类View
    @discardableResult
    public func buildTopClassifyView(classifyID: String, classifyViewIndex index: Int, topicDelegate delegate: ChatBootTopicCellProtocol?, refreshDelegate delegate1: ChatBootExploreRefreshProtocol?) -> ChatBootExploreDataSourceProtocol? {
        let _initFrame: CGRect = CGRect(origin: CGPointZero, size: CGSize(width: UIScreen.main.bounds.width, height: .zero))
        if index == .zero {
            let allClassifyView = LRChatBootExploreAllClassifyView(frame: _initFrame)
            self.addSubview(allClassifyView)
            allClassifyView.snp.makeConstraints { make in
                make.top.left.size.equalToSuperview()
            }
            allClassifyView.topicDelegate = delegate
            allClassifyView.refreshDelegate = delegate1
            classifyViewCache[index] = allClassifyView
        } else {
            let classifyView = LRChatBootExploreClassifyView(frame: _initFrame)
            self.addSubview(classifyView)
            classifyView.snp.makeConstraints { make in
                make.top.size.equalToSuperview()
                make.left.equalToSuperview().offset(self.width * CGFloat(index))
            }
            classifyView.topicDelegate = delegate
            classifyView.refreshDelegate = delegate1
            classifyViewCache[index] = classifyView
        }
        
        self.setContentOffset(CGPoint(x: self.width * CGFloat(index), y: .zero), animated: true)
        return classifyViewCache[index]
    }
    
    /// 滚动指定的分类
    @discardableResult
    public func scrollToSpecifiedCategory(classifyViewIndex index: Int) -> ChatBootExploreDataSourceProtocol? {
        self.setContentOffset(CGPoint(x: self.width * CGFloat(index), y: .zero), animated: true)
        return classifyViewCache[index]
    }
    
    /// 判断当前是否需要创建新的分类
    @discardableResult
    public func needBuildNewClassifyView(classifyViewIndex index: Int) -> ChatBootExploreDataSourceProtocol? {
        return classifyViewCache[index]
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
