//
//  LRChatBootExploreViewController.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//

import UIKit

class LRChatBootExploreViewController: LRChatBootBaseViewController, HideNavigationBarProtocol {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadExploreViews()
        layoutExploreViews()
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
        
        let titles: [String] = ["All", "Have Fun", "Traning", "Traning English", "Education", "Fun", "Daily Lifestyle"]
        var _source: [LRChatBootExploreModel] = []
        titles.enumerated().forEach { (index, item) in
            _source.append(LRChatBootExploreModel(topicClassification: item, topicClassificationID: String(index)))
        }
        
        self.sliderView.setSliderItems(titles: _source)
        self.horizationScrollView.contentSize = CGSize(width: self.view.width * CGFloat(titles.count), height: .zero)
        self.horizationScrollView.buildTopClassifyView(classifyID: _source.first!.topicClassificationID ?? "", classifyViewIndex: .zero, topicDelegate: self)
        
        self._inputBoxView = buildChatInputBoxView()
        
        self.sliderView.sliderDelegate = self
        
        self.view.addSubview(self.navView)
        self.view.addSubview(self.sliderView)
        self.view.addSubview(self.horizationScrollView)
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
        guard let _id = classificationID else {
            return
        }
        Log.debug("选择了分类ID === \(_id)")
        self.horizationScrollView.buildTopClassifyView(classifyID: _id, classifyViewIndex: classifyIndex, topicDelegate: self)
    }
}

// MARK: ChatBootTopicCellProtocol
extension LRChatBootExploreViewController: ChatBootTopicCellProtocol {
    func AI_selectedTopic(topicModel: LRChatBootTopicModel) {
        Log.debug("选择了话题 -------- \(topicModel.topic ?? "")")
        self.navigationController?.pushViewController(LRChatBootChatViewController(topicModel: topicModel), animated: true)
    }
}
