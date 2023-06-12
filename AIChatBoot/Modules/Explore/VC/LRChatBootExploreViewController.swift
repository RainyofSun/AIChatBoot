//
//  LRChatBootExploreViewController.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//

import UIKit
import MZRefresh

class LRChatBootExploreViewController: LRChatBootBaseViewController, HideNavigationBarProtocol {

    // 外界跳转至指定的分类
    open var specifyCategory: String?
    
    private lazy var navView: LRChatBootCustomNavView = {
        return LRChatBootCustomNavView(frame: CGRectZero, navStyle: LRChatBootCustomNavView.CustomNavigationType.Explore)
    }()
    
    private lazy var sliderView: LRChatBootExploreSliderView = {
        return LRChatBootExploreSliderView(frame: CGRectZero)
    }()
    
    private lazy var horizationScrollView: LRChatBootExploreHorizationScrollview = {
        return LRChatBootExploreHorizationScrollview(frame: CGRectZero)
    }()
    
    private var _inputBoxView: LRChatBootInputBoxView?
    // 当前分类的ID
    private var _current_category_id: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadExploreViews()
        layoutExploreViews()
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
}

// MARK: Private Methods
private extension LRChatBootExploreViewController {
    func loadExploreViews() {
        self.navView.navDelegate = self
        
        self._inputBoxView = buildChatInputBoxView()
        self._inputBoxView?.inputDelegate = self
        
        self.sliderView.sliderDelegate = self
        
        self.view.addSubview(self.navView)
        self.view.addSubview(self.sliderView)
        self.view.addSubview(self.horizationScrollView)
        
        // 全局配置刷新控件
        MZRefreshConfig.shareInstance.setRefreshStatusColor(APPThemeColor)
        MZRefreshConfig.shareInstance.setRefreshTimeColor(APPThemeColor)
    }
    
    func layoutExploreViews() {
        self.navView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview().offset(statusBarHeight())
        }
        
        self.sliderView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(self.navView.snp.bottom)
            make.height.equalTo(36)
        }
        
        self.horizationScrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(self.sliderView.snp.bottom).offset(3)
            make.bottom.equalTo(self._inputBoxView!.snp.top)
        }
    }
}

// MARK: Net Request
private extension LRChatBootExploreViewController {
    func requestQuestionCategory() {
        AIChatTarget().requestAIQuestionCategory {[weak self] response, error in
            guard error == nil else {
                Log.error("问题分类请求错误 ---- \(error?.localizedDescription ?? "")")
                self?.sliderView.removeIndicatorView()
                return
            }
            
            guard var _categories = [LRChatBootTopicCategoryModel].deserialize(from: response) as? [LRChatBootTopicCategoryModel] else {
                return
            }
            // 插入所有分类
            let _firstCategory: LRChatBootTopicCategoryModel = LRChatBootTopicCategoryModel.buildAllCategoryModel()
            self?._current_category_id = _firstCategory.categoryId
            _categories.insert(_firstCategory, at: .zero)
            // 更新分类
            self?.sliderView.setSliderItems(titles: _categories)
            // 设置contentSize
            self?.horizationScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(_categories.count), height: .zero)
            // 如果外界有指定分类 跳转至指定分类
            if let _s_c = self?.specifyCategory, let _index = _categories.firstIndex(where: {$0.categoryId == _s_c}) {
                self?.sliderView.scrollToSpecifyItem(itemIndex: _index)
            }
            // 默认显示全部分类
            else {
                let _protocol = self?.horizationScrollView.buildTopClassifyView(classifyID: _firstCategory.categoryId ?? "", classifyViewIndex: .zero, topicDelegate: self, refreshDelegate: self)
                _protocol?.AI_refreshQuestionGroupsUnderAllCategory(questions: [])
            }
        }
    }
    
    func requestQuestionGroupsUnderCategory(categoryID: String, pageNum page: Int = 1, completeHandler: (@escaping (_ source: [LRChatBootTopicModel]?) -> Void)) {
        AIChatTarget().requestAIQuestionList(params: ["categoryId": categoryID, "languageCode": Locale.current.languageCode ?? "en", "pageNum": page]) { response, error in
            guard error == nil else {
                Log.error("请求问题列表失败 ---- \(error?.localizedDescription ?? "")")
                completeHandler(nil)
                return
            }
            
            guard let _question_list = [LRChatBootTopicModel].deserialize(from: response) as? [LRChatBootTopicModel] else {
                return
            }
            
            completeHandler(_question_list)
        }
    }
}

// MARK: CustomNavProtocol
extension LRChatBootExploreViewController: CustomNavProtocol {
    func AI_goToSubscribePage() {
        self.goSubscribeControllerPage()
    }
    
    func AI_clickNavOperation() {
        self.navigationController?.pushViewController(LRChatBootSettingViewController(), animated: true)
    }
}

// MARK: ChatBootTopicCellProtocol
extension LRChatBootExploreViewController: ChatBootExploreSliderProtocol {
    func AI_selectedTopicClassification(classificationID: String?, classifyIndex: Int) {
        self._current_category_id = classificationID
        guard let _id = classificationID else {
            return
        }
        
        if let _classifyView = self.horizationScrollView.needBuildNewClassifyView(classifyViewIndex: classifyIndex) {
            Log.debug("已创建分类 -------- \(_classifyView)")
            self.horizationScrollView.scrollToSpecifiedCategory(classifyViewIndex: classifyIndex)
            return
        }
        
        self.horizationScrollView.buildTopClassifyView(classifyID: _id, classifyViewIndex: classifyIndex, topicDelegate: self, refreshDelegate: self)
    }
}

// MARK: ChatBootTopicCellProtocol
extension LRChatBootExploreViewController: ChatBootTopicCellProtocol {
    func AI_selectedTopic(topicModel: LRChatBootTopicModel) {
        self.navigationController?.pushViewController(LRChatBootChatViewController(topicModel: topicModel), animated: true)
    }
}

// MARK: ChatBootExploreRefreshProtocol
extension LRChatBootExploreViewController: ChatBootExploreRefreshProtocol {
    func AI_refreshCategoryDataSource(refreshView: ChatBootExploreDataSourceProtocol?) {
        guard let _id = self._current_category_id else {
            refreshView?.AI_questionGroupsDataLoadFailed()
            return
        }
        requestQuestionGroupsUnderCategory(categoryID: _id) { (source: [LRChatBootTopicModel]?) in
            guard let _s = source else {
                refreshView?.AI_questionGroupsDataLoadFailed()
                return
            }
            
            if refreshView is LRChatBootExploreClassifyView {
                refreshView?.AI_refreshQuestionGroupsUnderCategory(questions: _s)
            }
            
            if refreshView is LRChatBootExploreAllClassifyView {
                refreshView?.AI_refreshQuestionGroupsUnderAllCategory(questions: [_s])
            }
        }
    }
    
    func AI_loadMoreDataSource(refreshView: ChatBootExploreDataSourceProtocol?, currentPage: Int?) {
        guard let _id = self._current_category_id else {
            refreshView?.AI_questionGroupsDataLoadFailed()
            return
        }
        
        requestQuestionGroupsUnderCategory(categoryID: _id, pageNum: (currentPage ?? 1) + 1) { (source: [LRChatBootTopicModel]?) in
            guard let _s = source else {
                refreshView?.AI_questionGroupsDataLoadFailed()
                return
            }
            
            if refreshView is LRChatBootExploreClassifyView {
                if _s.isEmpty {
                    refreshView?.AI_noMoreQuestionGroupsUnderCategory(questions: _s)
                } else {
                    refreshView?.AI_loadMoreQuestionGroupsUnderCategory(questions: _s)
                }
            }
            
            if refreshView is LRChatBootExploreAllClassifyView {
                if _s.isEmpty {
                    refreshView?.AI_noMoreQuestionGroupsUnderAllCategory(questions: [_s])
                } else {
                    refreshView?.AI_loadMoreQuestionGroupsUnderAllCategory(questions: [_s])
                }
            }
        }
    }
}

// MARK: ChatBootInputBoxProtocol
extension LRChatBootExploreViewController: ChatBootInputBoxProtocol {
    func AI_inputBoxBeginEdit() {
        self.navigationController?.pushViewController(LRChatBootChatViewController(topicModel: nil), animated: true)
    }
}
