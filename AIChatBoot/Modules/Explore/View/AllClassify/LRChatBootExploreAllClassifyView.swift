//
//  LRChatBootExploreAllClassifyView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit
import MZRefresh

class LRChatBootExploreAllClassifyView: UIView, ChatBootExploreDataSourceProtocol {

    open weak var topicDelegate: ChatBootTopicCellProtocol?
    open weak var refreshDelegate: ChatBootExploreRefreshProtocol?
    
    private lazy var allClassifyTableView: UITableView = {
        let view = UITableView(frame: CGRectZero, style: UITableView.Style.plain)
        view.separatorStyle = .none
        view.backgroundColor = .clear
        return view
    }()
    
    private var indicatorView: UIActivityIndicatorView?
    private let ALL_CLASSIFY_CELL_ID: String = "com.explore.allClassifyCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadAllClassifyViews()
        layoutAllClassifyViews()
        self.indicatorView = buildActivityIndicatorView(activityViewStyle: UIActivityIndicatorView.Style.large)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    /// 更新数据
    func AI_refreshQuestionGroupsUnderAllCategory(questions: [[LRChatBootTopicModel]]) {
        AI_questionGroupsDataLoadFailed()
        
    }
    
    /// 加载更多数据
    func AI_loadMoreQuestionGroupsUnderAllCategory(questions: [[LRChatBootTopicModel]]) {
        
    }
    
    /// 数据全部加载完毕
    func AI_noMoreQuestionGroupsUnderAllCategory(questions: [[LRChatBootTopicModel]]) {
        
    }
    
    /// 数据加载失败
    func AI_questionGroupsDataLoadFailed() {
        self.allClassifyTableView.stopHeaderRefreshing()
        if self.indicatorView != nil {
            self.removeIndicatorView(activityView: self.indicatorView)
            self.indicatorView = nil
        }
    }
}

// MARK: Private Methods
private extension LRChatBootExploreAllClassifyView {
    func loadAllClassifyViews() {
        
        self.allClassifyTableView.delegate = self
        self.allClassifyTableView.dataSource = self
        
        self.allClassifyTableView.width = self.width
        self.allClassifyTableView.register(LRChatBootExploreAllClassifyCell.self, forCellReuseIdentifier: ALL_CLASSIFY_CELL_ID)
        self.allClassifyTableView.setRefreshHeader(MZRefreshNormalHeader(type: .lineScaleParty, color: APPThemeColor, beginRefresh: { [weak self] in
            self?.refreshDelegate?.AI_refreshCategoryDataSource(refreshView: self)
        }))
        
        self.addSubview(self.allClassifyTableView)
        self.allClassifyTableView.startHeaderRefreshing(animated: true)
    }
    
    func layoutAllClassifyViews() {
        self.allClassifyTableView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(10)
        }
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension LRChatBootExploreAllClassifyView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ALL_CLASSIFY_CELL_ID, for: indexPath) as? LRChatBootExploreAllClassifyCell else {
            return UITableViewCell()
        }
        cell.topicDelegate = self.topicDelegate
        return cell
    }
}
