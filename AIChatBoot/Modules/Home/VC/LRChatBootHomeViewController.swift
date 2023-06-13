//
//  LRChatBootHomeViewController.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//

import UIKit

class LRChatBootHomeViewController: LRChatBootBaseViewController, HideNavigationBarProtocol {

    private lazy var navView: LRChatBootCustomNavView = {
        return LRChatBootCustomNavView(frame: CGRectZero, navStyle: LRChatBootCustomNavView.CustomNavigationType.Home)
    }()
    
    private lazy var scrollView: LRChatBootHomeScrollView = {
        return LRChatBootHomeScrollView(frame: CGRectZero)
    }()
    
    private weak var _indicatorView: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadHomeViews()
        layoutHomeViews()
        requestQuestionCategory()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navView.resumeAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navView.pauseAnimation()
    }
    
    override func shouldBeSelected(_ tabbarController: LRTabbarViewController) -> Bool {
        // 刷新收藏数据
        self.refreshCollectionData()
        return true
    }
}

// MARK: Private Methods
private extension LRChatBootHomeViewController {
    func loadHomeViews() {
        
        self.scrollView.topicDelegate = self
        
        self.navView.navDelegate = self
        self.view.addSubview(self.navView)
        self.view.addSubview(self.scrollView)
        self._indicatorView = self.view.buildActivityIndicatorView(activityViewStyle: .large)
    }
    
    func layoutHomeViews() {
        self.navView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview().offset(statusBarHeight())
        }
        
        self.scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.navView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    func requestQuestionCategory() {
        AIChatTarget().requestAIQuestionCategory {[weak self] response, error in
            guard error == nil else {
                Log.error("问题分类请求错误 ---- \(error?.localizedDescription ?? "")")
                return
            }
            
            guard let _categories = [LRChatBootTopicCategoryModel].deserialize(from: response) as? [LRChatBootTopicCategoryModel] else {
                return
            }
            
            let _group: DispatchGroup = DispatchGroup()
            let workingQueue = DispatchQueue(label: "request_queue")
            workingQueue.async {
                _group.enter()
                // 取第一位作为热度话题
                AIChatTarget().requestAIQuestionList(params: ["categoryId": _categories.first?.categoryId ?? 3, "languageCode": Locale.current.languageCode ?? "en"]) { response, error in
                    guard error == nil else {
                        Log.error("请求问题列表失败 ---- \(error?.localizedDescription ?? "")")
                        _group.leave()
                        return
                    }
                    
                    guard let _question_list = [LRChatBootTopicModel].deserialize(from: response) as? [LRChatBootTopicModel] else {
                        _group.leave()
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self?.scrollView.hotTopicView.updateTopics(data: _question_list)
                        _group.leave()
                    }
                }
            }
            
            _group.enter()
            workingQueue.async {
                // 取最后一位作为推荐话题
                AIChatTarget().requestAIQuestionList(params: ["categoryId": _categories.last?.categoryId ?? 3, "languageCode": Locale.current.languageCode ?? "en"]) { response, error in
                    guard error == nil else {
                        Log.error("请求问题列表失败 ---- \(error?.localizedDescription ?? "")")
                        _group.leave()
                        return
                    }
                    
                    guard let _question_list = [LRChatBootTopicModel].deserialize(from: response) as? [LRChatBootTopicModel] else {
                        _group.leave()
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self?.scrollView.recommendTopicView.updateTopics(data: _question_list)
                        _group.leave()
                    }
                }
            }
            
            _group.notify(queue: workingQueue) {
                DispatchQueue.main.async {
                    self?.view.removeIndicatorView(activityView: self?._indicatorView)
                    self?._indicatorView = nil
                    self?.refreshCollectionData()
                }
            }
        }
    }
    
    // 刷新收藏数据
    func refreshCollectionData() {
        // 更新收藏数据
        if let _collection_data = LRChatBootTopicCollectionDB.shared.findChatTopicRecords(), !_collection_data.isEmpty {
            self.scrollView.addLikeViewToParentView()
            self.scrollView.likeTopicView.updateTopics(data: _collection_data)
        } else {
            self.scrollView.removeLikeViewFromParentView()
        }
    }
}

// MARK: CustomNavProtocol
extension LRChatBootHomeViewController: CustomNavProtocol {
    func AI_goToSubscribePage() {
        self.goSubscribeControllerPage()
    }
    
    func AI_clickNavOperation() {
        self.navigationController?.pushViewController(LRChatBootSettingViewController(), animated: true)
    }
}

// MARK: ChatBootTopicCellProtocol
extension LRChatBootHomeViewController: ChatBootTopicCellProtocol {
    func AI_selectedTopicClassification(classificationID: String?) {
        if let _index = self.tabBarController?.specialClassSubscript(className: "LRChatBootExploreViewController") {
            guard let _nav = self.tabBarController?.children[_index] as? LRNavigationViewController, let _rootVC = _nav.topViewController as? LRChatBootExploreViewController else {
                return
            }
            _rootVC.specifyCategory = classificationID
            self.tabBarController?.selectedIndex = _index
        }
    }
    
    func AI_selectedTopic(topicModel: LRChatBootTopicModel) {
        let _chatVC: LRChatBootChatViewController = LRChatBootChatViewController(topicModel: topicModel)
        _chatVC.refreshCollectionDataClosure = { [weak self] in
            self?.refreshCollectionData()
        }
        self.navigationController?.pushViewController(_chatVC, animated: true)
    }
}
