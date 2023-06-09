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
}

// MARK: Private Methods
private extension LRChatBootHomeViewController {
    func loadHomeViews() {
        
        var _bannerSource: [LRChatBootTopicModel] = []
        for index in 0..<4 {
            var _model = LRChatBootTopicModel()
            _model.topic = "Acts as a form generator. Users are free to fill the catalog and conten…"
            _model.hotTopics = "993390"
            _model.topicClassification = "Education_____\(index)"
            _model.topicClassificationID = "id_____\(index)"
            _bannerSource.append(_model)
        }
        
        self.scrollView.topicDelegate = self
        
        self.navView.navDelegate = self
        self.view.addSubview(self.navView)
        self.view.addSubview(self.scrollView)
        delay(1) {
            self.scrollView.recommendTopicView.updateTopics(data: _bannerSource)
            self.scrollView.likeTopicView.updateTopics(data: _bannerSource)
        }
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
            
            // 取第一位作为热度话题
            AIChatTarget().requestAIQuestionList(params: ["categoryId": _categories.first?.categoryId ?? 3, "languageCode": Locale.current.languageCode ?? "en"]) { response, error in
                guard error == nil else {
                    Log.error("请求问题列表失败 ---- \(error?.localizedDescription ?? "")")
                    return
                }
                
                guard let _question_list = [LRChatBootTopicModel].deserialize(from: response) as? [LRChatBootTopicModel] else {
                    return
                }
                
                self?.scrollView.hotTopicView.updateTopics(data: _question_list)
            }
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
        Log.debug("分类ID ===== \(classificationID)")
    }
    
    func AI_selectedTopic(topicModel: LRChatBootTopicModel) {
        Log.debug("选择了 ----- \(topicModel.topic ?? "")")
        self.navigationController?.pushViewController(LRChatBootChatViewController(topicModel: topicModel), animated: true)
    }
}
