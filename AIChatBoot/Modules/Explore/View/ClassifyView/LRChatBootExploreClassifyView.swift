//
//  LRChatBootExploreClassifyView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/30.
//

import UIKit
import MZRefresh

class LRChatBootExploreClassifyView: UIView, ChatBootExploreDataSourceProtocol {

    open weak var topicDelegate: ChatBootTopicCellProtocol?
    open weak var refreshDelegate: ChatBootExploreRefreshProtocol?
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 30) * 0.5, height: (UIScreen.main.bounds.width - 30) * 0.43)
        return layout
    }()
    
    private lazy var topicCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 5, right: 10)
        return collectionView
    }()
    
    private var indicatorView: UIActivityIndicatorView?
    private let CLASSIFY_CELL_ID = "com.AI.calssify.cell"
    private var _category_source: [LRChatBootTopicModel]?
    // 当前加载的页数
    private var _current_page: Int = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadClassifyViews()
        layoutClassifyViews()
        self.indicatorView = buildActivityIndicatorView(activityViewStyle: UIActivityIndicatorView.Style.large)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    /// 刷新数据
    func AI_refreshQuestionGroupsUnderCategory(questions: [LRChatBootTopicModel]) {
        // 重置页数
        self._current_page = 1
        AI_questionGroupsDataLoadFailed()
        _category_source?.removeAll()
        _category_source = questions
        self.topicCollectionView.reloadData()
    }
    
    /// 加载更多数据
    func AI_loadMoreQuestionGroupsUnderCategory(questions: [LRChatBootTopicModel]) {
        self.topicCollectionView.stopFooterRefreshing()
        // 页数累加
        self._current_page += 1
        _category_source?.append(contentsOf: questions)
        self.topicCollectionView.reloadData()
    }
    
    /// 数据全部加载完毕
    func AI_noMoreQuestionGroupsUnderCategory(questions: [LRChatBootTopicModel]) {
        self.topicCollectionView.stopFooterRefreshing()
        // 页数累加
        self._current_page += 1
        _category_source?.append(contentsOf: questions)
        self.topicCollectionView.stopHeaderRefreshingWithNoMoreData()
    }
    
    /// 数据加载失败
    func AI_questionGroupsDataLoadFailed() {
        self.topicCollectionView.stopHeaderRefreshing()
        self.topicCollectionView.stopFooterRefreshing()
        if self.indicatorView != nil {
            self.removeIndicatorView(activityView: self.indicatorView)
            self.indicatorView = nil
        }
    }
}

// MARK: Private Methods
private extension LRChatBootExploreClassifyView {
    func loadClassifyViews() {
        
        self.topicCollectionView.width = self.width
        self.topicCollectionView.register(LRChatBootExploreClassifyCell.self, forCellWithReuseIdentifier: CLASSIFY_CELL_ID)
        self.topicCollectionView.setRefreshHeader(MZRefreshNormalHeader(type: .lineScaleParty, color: APPThemeColor, beginRefresh: { [weak self] in
            self?.refreshDelegate?.AI_refreshCategoryDataSource(refreshView: self)
        }))
        
        self.topicCollectionView.setRefreshFooter(MZRefreshNormalFooter(type: .lineScaleParty, color: APPThemeColor, beginRefresh: { [weak self] in
            self?.refreshDelegate?.AI_loadMoreDataSource(refreshView: self, currentPage: self?._current_page)
        }))
        
        
        self.addSubview(self.topicCollectionView)
        self.topicCollectionView.startHeaderRefreshing(animated: true)
    }
    
    func layoutClassifyViews() {
        self.topicCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension LRChatBootExploreClassifyView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _category_source?.count ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CLASSIFY_CELL_ID, for: indexPath) as? LRChatBootExploreClassifyCell else {
            return UICollectionViewCell()
        }
        
        if let _model = _category_source?[indexPath.item] {
            cell.reloadCellSource(model: _model)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let _model = _category_source?[indexPath.item] else {
            return
        }
        self.topicDelegate?.AI_selectedTopic(topicModel: _model)
    }
}
