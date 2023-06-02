//
//  LRTextContentView.swift
//  expandTableView
//
//  Created by 苍蓝猛兽 on 2023/6/2.
//

import UIKit

protocol TextContentViewDataSource: AnyObject {
    /**
     输入框字体，默认 15
     */
    func textFontOfTextContentView() -> UIFont

    /**
     无文本状态下输入框的高度，默认 40
     */
    func preferredHeightOfTextContentView() -> CGFloat

    /**
     输入框最多显示行数，默认 4
     */
    func maximumLineOfTextContentView() -> Int
    
    /**
     输入框占位文字
     */
    func inputBoxPlaceholderText() -> String?
}

class LRTextContentView: UIView {

    weak open var dataSource: TextContentViewDataSource? {
        didSet {
            if let _f = dataSource?.textFontOfTextContentView() {
                self.textView.font = _f
            }
            if let _s = dataSource?.inputBoxPlaceholderText() {
                self.textView.placeHolder = _s
            }
        }
    }
    
    private(set) var textView: LRTextView = {
        let textView = LRTextView(frame: CGRectZero)
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textContainerInset = .zero
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private Methods
private extension LRTextContentView {
    func setup() {
        let lineHeight: CGFloat = self.textView.font?.lineHeight ?? 17
        let lineNum: Int = self.dataSource?.maximumLineOfTextContentView() ?? 4
        let maxHeight: CGFloat = lineHeight * CGFloat(lineNum)
        
        let preferredHeight: CGFloat = self.dataSource?.preferredHeightOfTextContentView() ?? 40
        let topMargin: CGFloat = (preferredHeight - lineHeight) * 0.5
        
        self.layer.cornerRadius = preferredHeight * 0.5
        self.clipsToBounds = true
        
        self.addSubview(self.textView)
        self.textView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(8)
            make.verticalEdges.equalToSuperview().inset(topMargin)
            make.height.equalTo(lineHeight)
            make.height.greaterThanOrEqualTo(lineHeight)
            make.height.lessThanOrEqualTo(maxHeight)
        }
        
        self.textView.associateConstraints()
    }
}
