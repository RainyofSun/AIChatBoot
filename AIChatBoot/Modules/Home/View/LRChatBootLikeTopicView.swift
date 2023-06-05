//
//  LRChatBootLikeTopicView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit

class LRChatBootLikeTopicView: LRChatBootTopicClassificationView {
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = .zero
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 200 * 0.75)
        return layout
    }()
    
    private lazy var likeCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = true
        return collectionView
    }()
    
    private var _topic_source: [LRChatBootTopicModel]?
    private let LIKE_TOPIC_CELL_ID: String = "com.AI.like.cell"
    
    override func loadTopicViews() {
        super.loadTopicViews()
        self.backgroundColor = WhiteColor
        self.titleLab.attributedText = attributeTitle(title: LRLocalizableManager.localValue("homeLike"), imageName: "home_icon_Your Likes")
        
        self.likeCollectionView.register(LRChatBootLikeTopicCell.self, forCellWithReuseIdentifier: LIKE_TOPIC_CELL_ID)
        self.likeCollectionView.contentInset = UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 10)
        
        self.addSubview(self.likeCollectionView)
    }
    
    override func layoutTopicViews() {
        super.layoutTopicViews()
        self.likeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLab.snp.bottom).offset(10)
            make.width.left.equalToSuperview()
            make.height.equalTo(self.snp.width).multipliedBy(0.39)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: Public Methods
    /// 更新话题
    override func updateTopics(data: [LRChatBootTopicModel]) {
        _topic_source = data
        self.likeCollectionView.reloadData()
    }
}

// MARK: Private Methods
private extension LRChatBootLikeTopicView {
    
}

// MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension LRChatBootLikeTopicView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _topic_source?.count ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LIKE_TOPIC_CELL_ID, for: indexPath) as? LRChatBootLikeTopicCell else {
            return UICollectionViewCell()
        }
        
        if let _model = _topic_source?[indexPath.item] {
            cell.reloadTopicCellSource(model: _model)
        }
        cell.cellDelegate = self.topicDelegate
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let _model = _topic_source?[indexPath.row] else {
            return
        }
        self.topicDelegate?.AI_selectedTopic(topicModel: _model)
    }
}
