//
//  LRChatBootInputBoxView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/26.
//

import UIKit

protocol ChatBootInputBoxProtocol: AnyObject {
    /// 编辑开始
    func AI_inputBoxBeginEdit()
    /// 发送信息
    func AI_sendQuestion(question: String)
    /// 是否可以发送新的消息
    func AI_canSendNewQuestion() -> Bool
}

extension ChatBootInputBoxProtocol {
    /// 是否可以进行编辑
    func AI_inputBoxBeginEdit() {
        
    }
    
    /// 发送信息
    func AI_sendQuestion(question: String) {
        
    }
    
    /// 是否可以发送新的消息
    func AI_canSendNewQuestion() -> Bool {
        return false
    }
}

class LRChatBootInputBoxView: UIView {

    weak open var inputDelegate: ChatBootInputBoxProtocol?
    
    /// 是否可以输入
    open var canInput: Bool = false {
        didSet {
            if canInput {
                addKeyboardNotification()
            }
        }
    }
    
    private lazy var textContentView: LRTextContentView = {
        let view = LRTextContentView(frame: CGRectZero)
        view.textView.backgroundColor = UIColor.init(hexString: "#121212")
        view.textView.placeHolderTextColor = UIColor(hexString: "#767676")
        view.textView.placeHolder = LRLocalizableManager.localValue("inputBoxPlaceholder")
        view.textView.textColor = WhiteColor
        view.textView.tintColor = APPThemeColor
        view.backgroundColor = view.textView.backgroundColor
        return view
    }()

    private lazy var sendBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setImage(UIImage(named: "chat_icon_send"), for: UIControl.State.normal)
        btn.setImage(UIImage(named: "chat_icon_send"), for: UIControl.State.highlighted)
        return btn
    }()
    
    private let MAX_TEXT_LENGTH: Int = 500
    // 记录键盘弹出的初始高度
    var _ketboardHeight: CGFloat = CGFloat.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadInputBoxViews()
        layoutInputBoxViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if canInput {
            removeKeyboardNotification()
        }
        deallocPrint()
    }
    
    // MARK: Public Methods
    /// 重置第一响应者
    public func resignInputBoxFirstResponder() {
        if self.textContentView.textView.canResignFirstResponder {
            self.textContentView.textView.resignFirstResponder()
        }
    }
    
    /// 外界设置预设话题
    public func setDefaultTopic(topic: String) {
        self.textContentView.textView.text = topic
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            if self.textContentView.textView.canBecomeFirstResponder {
                self.textContentView.textView.becomeFirstResponder()
            }
        })
    }
}

// MARK: Private Methods
private extension LRChatBootInputBoxView {
    func loadInputBoxViews() {
        self.backgroundColor = .black
        self.roundCorners([.topLeft, .topRight], radius: 20)
        
        self.sendBtn.addTarget(self, action: #selector(clickSendButton(sender: )), for: UIControl.Event.touchUpInside)
        self.textContentView.textView.delegate = self
    
        self.addSubview(self.textContentView)
        self.addSubview(self.sendBtn)
        
        self.textContentView.textView.heightChangeBlock = { [weak self] in
            self?.superview?.layoutIfNeeded()
        }
    }
    
    func layoutInputBoxViews() {
        
        self.textContentView.snp.remakeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(25)
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(self.sendBtn.snp.left).offset(-15)
        }
        
        self.sendBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.size.equalTo(40)
        }
    }
    
    /// 添加键盘监听
    func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardDidHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardHeightChange(notification: )), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    /// 移除键盘监听
    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

// MARK: Notification
@objc extension LRChatBootInputBoxView {
    func systemKeyboardWillShow(notification: Notification) {
        let beginKeyboardRect = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] ?? CGRect.zero
        let endKeyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] ?? CGRect.zero
        let animationTime = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? APPAnimationDurationTime
        guard let beginRect = beginKeyboardRect as? CGRect, let endRect = endKeyboardRect as? CGRect, endRect.height != CGFloat.zero, endRect.height >= 200 else {
            return
        }
        Log.debug("键盘升起矫正布局 --------- begin = \(beginRect)  end = \(endRect)")
        // 记录键盘的初始高度
        _ketboardHeight = endRect.height
        UIView.animate(withDuration: animationTime, delay: .zero, options: UIView.AnimationOptions.curveEaseInOut) {
            self.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(-endRect.height)
            }
            self.superview?.layoutIfNeeded()
        }
    }
    
    func systemKeyboardDidHide(notification: Notification) {
        let beginKeyboardRect = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] ?? CGRect.zero
        let endKeyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] ?? CGRect.zero
        let animationTime = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? APPAnimationDurationTime
        guard let beginRect = beginKeyboardRect as? CGRect, let endRect = endKeyboardRect as? CGRect, endRect.height != CGFloat.zero else {
            return
        }
        Log.debug("键盘高度 keyboardRect 退下 --------- begin = \(beginRect)  end = \(endRect)")
        UIView.animate(withDuration: animationTime, delay: .zero, options: UIView.AnimationOptions.curveEaseInOut) {
            self.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            // 重置键盘的高度
            self._ketboardHeight = .zero
        }
    }
    
    func systemKeyboardHeightChange(notification: Notification) {
        let endKeyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] ?? CGRect.zero
        guard let endRect = endKeyboardRect as? CGRect, endRect.height != .zero else {
            return
        }
        if _ketboardHeight != .zero && endRect.height != _ketboardHeight {
            Log.debug("键盘高度发生了变化,矫正输入框的布局 ------------------ endRect = \(endRect) _keyboardHeight = \(_ketboardHeight)")
        }
    }
}

// MARK: UITextViewDelegate
extension LRChatBootInputBoxView: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.inputDelegate?.AI_inputBoxBeginEdit()
        return canInput
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.isEmpty && text.isEmpty {
            textView.text = nil
        }
        if text.isEmpty {
            return true
        }
        return textView.text.count < MAX_TEXT_LENGTH
    }
}

// MARK: Target
@objc private extension LRChatBootInputBoxView {
    func clickSendButton(sender: UIButton) {
        guard let _text = self.textContentView.textView.text, !_text.isEmpty else {
            return
        }
        
        if let _can = self.inputDelegate?.AI_canSendNewQuestion(), !_can {
            Log.debug("动画未结束,不允许发送新的消息 --------------")
            self.resignInputBoxFirstResponder()
            return
        }
        
        self.textContentView.textView.text = nil
        self.resignInputBoxFirstResponder()
        
        self.inputDelegate?.AI_sendQuestion(question: _text)
    }
}
