//
//  LRChatBootExploreSliderView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit

class LRChatBootExploreSliderView: UIScrollView {

    weak open var sliderDelegate: ChatBootExploreSliderProtocol?
    
    private let TAG_INCREASE: Int = 1000
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadSliderViews()
        layoutSliderViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func setSliderItems(titles: [LRChatBootExploreModel]) {
        var _lastItem: LRChatBootExploreSliderItem?
        titles.enumerated().forEach { (index: Int, exploreModel: LRChatBootExploreModel) in
            guard let _category = exploreModel.topicClassification else {
                return
            }
            let _item = LRChatBootExploreSliderItem(frame: CGRectZero)
            _item.setTitle(_category, for: UIControl.State.normal)
            _item.setTitle(_category, for: UIControl.State.selected)
            _item.isSelected = (index == .zero)
            _item.tag = index + TAG_INCREASE
            _item.classificationID = exploreModel.topicClassificationID
            _item.addTarget(self, action: #selector(clickSlider(sender: )), for: UIControl.Event.touchUpInside)
            
            var _textW = _category.textWidth(font: UIFont.boldSystemFont(ofSize: 17), height: 24) + 20
            _textW = max(60, _textW)
            self.addSubview(_item)
            if let _l = _lastItem {
                if index + 1 == titles.count {
                    _item.snp.makeConstraints { make in
                        make.left.equalTo(_l.snp.right).offset(15)
                        make.centerY.height.equalTo(_l)
                        make.width.equalTo(_textW)
                        make.right.equalToSuperview()
                    }
                } else {
                    _item.snp.makeConstraints { make in
                        make.left.equalTo(_l.snp.right).offset(15)
                        make.centerY.height.equalTo(_l)
                        make.width.equalTo(_textW)
                    }
                }
            } else {
                if titles.count == 1 {
                    _item.snp.makeConstraints { make in
                        make.top.left.height.equalToSuperview()
                        make.width.equalTo(_textW)
                        make.right.equalToSuperview()
                    }
                } else {
                    _item.snp.makeConstraints { make in
                        make.top.left.height.equalToSuperview()
                        make.width.equalTo(_textW)
                    }
                }
            }
            _lastItem = _item
        }
    }
}

// MARK: Private Methods
private extension LRChatBootExploreSliderView {
    func loadSliderViews() {
        self.alwaysBounceHorizontal = true
        self.showsHorizontalScrollIndicator = false
        self.contentInset = UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 10)
    }
    
    func layoutSliderViews() {
        
    }
}

// MARK: Target
@objc private extension LRChatBootExploreSliderView {
    func clickSlider(sender: LRChatBootExploreSliderItem) {
        if sender.isSelected {
            return
        }
        // 重置状态
        self.subviews.forEach { (subView: UIView) in
            guard let _item = subView as? LRChatBootExploreSliderItem else {
                return
            }
            _item.isSelected = false
        }
        sender.isSelected = !sender.isSelected
        // 位置检测
        let _right = sender.x + sender.width
        if _right > self.width {
            self.setContentOffset(CGPoint(x: (_right - self.width), y: .zero), animated: true)
        }
        self.sliderDelegate?.AI_selectedTopicClassification(classificationID: sender.classificationID, classifyIndex: (sender.tag - TAG_INCREASE))
    }
}
