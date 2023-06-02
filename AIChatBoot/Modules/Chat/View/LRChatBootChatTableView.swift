//
//  LRChatBootChatTableView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/31.
//

import UIKit

class LRChatBootChatTableView: UITableView {
    
    open var resignFirstResponderHandler: (()->())?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.separatorStyle = .none
        self.backgroundColor = .clear
        self.contentInset = UIEdgeInsets(top: .zero, left: .zero, bottom: 10, right: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resignFirstResponderHandler?()
    }

    deinit {
        deallocPrint()
    }
}

extension LRChatBootChatTableView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.resignFirstResponderHandler?()
    }
}
