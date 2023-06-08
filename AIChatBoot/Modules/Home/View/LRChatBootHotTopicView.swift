//
//  LRChatBootHotTopicView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit

class LRChatBootHotTopicView: LRChatBootTopicClassificationView {

    private lazy var topicTabView: UITableView = {
        let view = UITableView(frame: CGRectZero, style: UITableView.Style.plain)
        view.separatorStyle = .none
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var _hot_topic_source: [LRChatBootTopicModel]?
    private let HOT_TOPIC_CELL_ID: String = "com.AI.hot.cell"
    
    override func loadTopicViews() {
        super.loadTopicViews()
        self.backgroundColor = UIColor(hexString: "#333B80")
        self.titleLab.attributedText = attributeTitle(title: LRLocalizableManager.localValue("homeHot"), imageName: "home_icon_topicHot", imageTopAscend: -1, foregroundColor: WhiteColor)
    
        self.topicTabView.register(LRChatBootHotTopicCell.self, forCellReuseIdentifier: HOT_TOPIC_CELL_ID)
        self.topicTabView.delegate = self
        self.topicTabView.dataSource = self
        
        self.addSubview(self.topicTabView)
    }
    
    override func layoutTopicViews() {
        super.layoutTopicViews()
        
        self.topicTabView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLab.snp.bottom).offset(10)
            make.height.equalTo(1)
            make.width.left.bottom.equalToSuperview()
        }
    }
    
    // MARK: Public Methpds
    /// 更新热度话题
    override func updateTopics(data: [LRChatBootTopicModel]) {
        _hot_topic_source = data
        self.topicTabView.reloadData()
        UIView.animate(withDuration: APPAnimationDurationTime, delay: .zero, options: UIView.AnimationOptions.curveEaseOut) {
            self.topicTabView.snp.updateConstraints { make in
                make.height.equalTo(115 * data.count)
            }
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension LRChatBootHotTopicView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _hot_topic_source?.count ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HOT_TOPIC_CELL_ID, for: indexPath) as? LRChatBootHotTopicCell else {
            return UITableViewCell()
        }
        
        if let _model = _hot_topic_source?[indexPath.row] {
            cell.reloadTopicCellSource(model: _model)
        }
        cell.cellDelegate = self.topicDelegate
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _model = _hot_topic_source?[indexPath.row] else {
            return
        }
        self.topicDelegate?.AI_selectedTopic(topicModel: _model)
    }
}
