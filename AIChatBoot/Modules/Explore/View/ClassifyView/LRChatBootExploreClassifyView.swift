//
//  LRChatBootExploreClassifyView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/30.
//

import UIKit

class LRChatBootExploreClassifyView: UIView {

    open weak var topicDelegate: ChatBootTopicCellProtocol?
    
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
    
    private let CLASSIFY_CELL_ID = "com.AI.calssify.cell"
    private var _category_source: [LRChatBootTopicModel]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadClassifyViews()
        layoutClassifyViews()
        testData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    /// 更新分类话题
    public func updateTopicCalssifySource(data: [LRChatBootTopicModel]) {
        _category_source = data
        self.topicCollectionView.reloadData()
    }
}

// MARK: Private Methods
private extension LRChatBootExploreClassifyView {
    func loadClassifyViews() {
        
        self.topicCollectionView.register(LRChatBootExploreClassifyCell.self, forCellWithReuseIdentifier: CLASSIFY_CELL_ID)
        
        self.addSubview(self.topicCollectionView)
    }
    
    func layoutClassifyViews() {
        self.topicCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // TODO: 测试数据
    func testData() {
        var _bannerSource: [LRChatBootTopicModel] = []
        for _ in 0..<40 {
            var _model = LRChatBootTopicModel()
            _model.topic = "Acts as a form generator. Users are free to fill the catalog and conten…"
            _model.topicClassification = "Education"
            _bannerSource.append(_model)
        }
        self.updateTopicCalssifySource(data: _bannerSource)
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
