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
    
    var label : UILabel!
    
    private var _charStr: String = "When you’re building apps, the entry barrier to some features, including text recognition, is high.When you’re building apps, the entry barrier to some features, including text recognition, is high.When you’re building apps, the entry barrier to some features, including text recognition, is high.When you’re building apps, the entry barrier to some features, including text recognition, is high.When you’re building apps, the entry barrier to some features, including text recognition, is high.When you’re building apps, the entry barrier to some features, including text recognition, is high."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadHomeViews()
        layoutHomeViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navView.resumeAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navView.pauseAnimation()
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
////        self._mutableStr = NSMutableAttributedString(string: _charStr, attributes: [.foregroundColor: UIColor.clear, .font: UIFont.systemFont(ofSize: 15)])
////        _textLayer.string = self._mutableStr
////        _linkTimer = CADisplayLink(target: self, selector: #selector(dispalyAnimation))
////        _linkTimer?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
//        label.isHidden = true
//        let animation = LRChatBootStringAppearOneByOneAnimation()
//        animation.appearDuration = 0.1
////        let animation = LRChatBootStringAppearStreamingAnimation()
//        self.label.animation_startAnimation(animation)
//    }
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
        self.scrollView.recommendTopicView.updateTopics(data: _bannerSource)
        self.scrollView.likeTopicView.updateTopics(data: _bannerSource)
        self.scrollView.hotTopicView.updateTopics(data: _bannerSource)
        
        self.navView.navDelegate = self
        self.view.addSubview(self.navView)
        self.view.addSubview(self.scrollView)
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
    
    func testTextAnimation() {
        label = UILabel(frame: CGRect(x:0,y:0,width:self.view.frame.size.width - 20,height: 0))
        label.numberOfLines = 0
        label.text = _charStr
        label.isHidden = true
        self.view.addSubview(label)
        label.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(10)
        }
    }
    
    func testNet() {
        
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
