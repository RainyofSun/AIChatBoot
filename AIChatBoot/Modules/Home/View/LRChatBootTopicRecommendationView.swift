//
//  LRChatBootTopicRecommendationView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit
import ZCycleView

class LRChatBootTopicRecommendationView: LRChatBootTopicClassificationView {

    // 轮播图
    private lazy var cycleView: ZCycleView = {
        let view = ZCycleView(frame: CGRectZero)
        view.scrollDirection = .horizontal
        view.itemSpacing = 10
        return view
    }()
    
    override func loadTopicViews() {
        super.loadTopicViews()
        self.backgroundColor = UIColor(hexString: "#C4D160")
        self.titleLab.attributedText = self.attributeTitle(title: LRLocalizableManager.localValue("homeRecommend"), imageName: "home_icon_You Might Like")
        cycleView.delegate = self
        self.addSubview(cycleView)
    }

    private var _banner_source: [LRChatBootTopicModel]?
    private let BANNER_CELL_ID: String = "com.AI.banner.cell"
    
    override func layoutTopicViews() {
        super.layoutTopicViews()
        cycleView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLab.snp.bottom)
            make.left.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(self.snp.width).multipliedBy(0.4)
        }
    }
    
    // MARK: Public Methods
    // 更新轮播图数据
    override func updateTopics(data: [LRChatBootTopicModel]) {
        _banner_source = data
        cycleView.reloadItemsCount(_banner_source?.count ?? .zero)
        cycleView.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: (UIScreen.main.bounds.width - 20) * 0.3)
    }
}

// MARK: ZCycleViewProtocol
extension LRChatBootTopicRecommendationView: ZCycleViewProtocol {
    func cycleViewRegisterCellClasses() -> [String : AnyClass] {
        return [BANNER_CELL_ID : LRChatBootTopicCell.self]
    }
    
    func cycleViewConfigureCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, realIndex: Int) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BANNER_CELL_ID, for: indexPath) as? LRChatBootTopicCell else {
            return UICollectionViewCell()
        }
        if let _model = _banner_source?[realIndex] {
            cell.reloadTopicCellSource(model: _model)
        }
        cell.cellDelegate = self.topicDelegate
        return cell
    }
    
    func cycleViewDidScrollToIndex(_ cycleView: ZCycleView, index: Int) {
        
    }
    
    func cycleViewDidSelectedIndex(_ cycleView: ZCycleView, index: Int) {
        guard let _model = _banner_source?[index] else {
            return
        }
        self.topicDelegate?.AI_selectedTopic(topicModel: _model)
    }
    
    func cycleViewConfigurePageControl(_ cycleView: ZCycleView, pageControl: ZPageControl) {
        pageControl.isHidden = false
        pageControl.currentPageIndicatorTintColor = UIColor(white: .zero, alpha: 0.7)
        pageControl.pageIndicatorTintColor = UIColor(white: .zero, alpha: 0.1)
        pageControl.frame = CGRect(x: 0, y: cycleView.bounds.height - 25, width: cycleView.bounds.width, height: 25)
    }
}
