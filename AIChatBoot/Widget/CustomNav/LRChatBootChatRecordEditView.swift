//
//  LRChatBootChatRecordEditView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/30.
//

import UIKit

protocol ChatRecordEditProtocol: AnyObject {
    /// 点击全选
    func AI_selectedAll(isSelectedAll: Bool)
    /// 点击取消
    func AI_cancelSelection()
}

class LRChatBootChatRecordEditView: UIView {
    
    weak open var editDelegate: ChatRecordEditProtocol?
    
    private lazy var selectedAllBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setTitle(LRLocalizableManager.localValue("historySelectAll"), for: UIControl.State.normal)
        btn.setTitle(LRLocalizableManager.localValue("historyDeselectAll"), for: UIControl.State.selected)
        btn.setTitleColor(APPThemeColor, for: UIControl.State.normal)
        btn.setTitleColor(APPThemeColor, for: UIControl.State.selected)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        return btn
    }()
    
    private lazy var doneBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setTitle(LRLocalizableManager.localValue("historyDone"), for: UIControl.State.normal)
        btn.setTitle(LRLocalizableManager.localValue("historyDone"), for: UIControl.State.highlighted)
        btn.setTitleColor(APPThemeColor, for: UIControl.State.normal)
        btn.setTitleColor(APPThemeColor, for: UIControl.State.highlighted)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadEditViews()
        layoutEditViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    /// 重置全选按钮状态
    public func resetSelectedAllButtonStatus(isSelected: Bool) {
        self.selectedAllBtn.isSelected = isSelected
    }
}

// MARK: Private Methods
private extension LRChatBootChatRecordEditView {
    func loadEditViews() {
        self.selectedAllBtn.addTarget(self, action: #selector(clickSelectedButton(sender: )), for: UIControl.Event.touchUpInside)
        self.doneBtn.addTarget(self, action: #selector(clickDoneButton(sender: )), for: UIControl.Event.touchUpInside)
        
        self.addSubview(self.selectedAllBtn)
        self.addSubview(self.doneBtn)
    }
    
    func layoutEditViews() {
        self.selectedAllBtn.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(20)
            make.left.equalToSuperview().offset(15)
        }
        
        self.doneBtn.snp.makeConstraints { make in
            make.centerY.equalTo(self.selectedAllBtn)
            make.right.equalToSuperview().offset(-15)
        }
    }
}

// MARK: Target
@objc private extension LRChatBootChatRecordEditView {
    func clickSelectedButton(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.editDelegate?.AI_selectedAll(isSelectedAll: sender.isSelected)
    }
    
    func clickDoneButton(sender: UIButton) {
        self.selectedAllBtn.isSelected = false
        self.editDelegate?.AI_cancelSelection()
    }
}
