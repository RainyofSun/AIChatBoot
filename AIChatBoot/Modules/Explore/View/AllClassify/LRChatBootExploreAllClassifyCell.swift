//
//  LRChatBootExploreAllClassifyCell.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit

class LRChatBootExploreAllClassifyCell: UITableViewCell {

    open weak var topicDelegate: ChatBootTopicCellProtocol?
    
    private lazy var titleLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.textColor = WhiteColor
        lab.font = APPFont(20)
        lab.text = "All Classify"
        return lab
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = .zero
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 160, height: 150)
        return layout
    }()
    
    private lazy var topicCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = true
        return collectionView
    }()
    
    private let ALL_CLASSIFY_CELL_ID = "com.AI.all.cell"
    private var _category_source: [LRChatBootTopicModel]?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadCellViews()
        layoutCellViews()
        testData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
private extension LRChatBootExploreAllClassifyCell {
    func loadCellViews() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.topicCollectionView.register(LRChatBootExploreClassifyCell.self, forCellWithReuseIdentifier: ALL_CLASSIFY_CELL_ID)
        
        self.contentView.addSubview(self.titleLab)
        self.contentView.addSubview(self.topicCollectionView)
    }
    
    func layoutCellViews() {
        self.titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        self.topicCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(self.titleLab.snp.bottom).offset(10)
            make.height.equalTo(160)
            make.width.bottom.equalToSuperview()
        }
    }
    
    // TODO: 测试数据
    func testData() {
        var _bannerSource: [LRChatBootTopicModel] = []
        for _ in 0..<4 {
            var _model = LRChatBootTopicModel()
            _model.topic = "Acts as a form generator. Users are free to fill the catalog and conten…"
            _model.topicClassification = "Education"
            _bannerSource.append(_model)
        }
        self.updateTopicCalssifySource(data: _bannerSource)
    }
}

// MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension LRChatBootExploreAllClassifyCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _category_source?.count ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ALL_CLASSIFY_CELL_ID, for: indexPath) as? LRChatBootExploreClassifyCell else {
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
