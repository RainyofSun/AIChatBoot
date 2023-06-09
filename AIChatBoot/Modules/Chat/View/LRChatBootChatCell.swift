//
//  LRChatBootChatCell.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/31.
//

import UIKit

class LRChatBootChatCell: UITableViewCell {

    weak open var chatAnimationDelegate: ChatBootAIChatAnimationProtocol?
    
    /// Cell标记
    open var cellMark: IndexPath?
    
    private(set) lazy var userHeadImageView: UIImageView = {
        return UIImageView(image: UIImage(named: "chat_icon_user"))
    }()
    
    private(set) lazy var contentLab: UILabel = {
        let lab = UILabel(frame: CGRect(origin: CGPointMake(56, 15), size: CGSize(width: (UIScreen.main.bounds.width - 66), height: .zero)))
        lab.numberOfLines = .zero
        lab.isHidden = true
        return lab
    }()
    
    private weak var _text_animation: LRChatBootStringAnimation?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadChatCellViews()
        layoutChatCellViews()
        hookMenthods()
        addNotification()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeNotification()
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func reloadChatCellSource(chatModel: LRChatBootChatModel) {
        self.contentLab.attributedText = NSMutableAttributedString(string: chatModel.chatContent, attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: WhiteColor])
        self.contentLab.isHidden = !chatModel.animationComplete
        if chatModel.animationComplete {
            return
        }
        delay(0.2) {
            self.chatAnimationDelegate?.AI_animationComplete(isEnd: false, cellMark: self.cellMark)
            let animation = LRChatBootStringAppearOneByOneAnimation()
            animation.appearDuration = 0.01
            self.contentLab.animation_startAnimation(animation)
            animation.animationComplete = { [weak self] in
                self?._text_animation = nil
                self?.animationStop()
                self?.chatAnimationDelegate?.AI_animationComplete(isEnd: true, cellMark: self?.cellMark)
            }
            self._text_animation = animation
        }
    }
    
    // MARK: Hook Methods
    public func hookMenthods() {
        
    }
    
    public func animationStop() {
        
    }
}

// MARK: Private Methods
private extension LRChatBootChatCell {
    func loadChatCellViews() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.contentView.addSubview(self.userHeadImageView)
        self.contentView.addSubview(self.contentLab)
    }
    
    func layoutChatCellViews() {
        self.userHeadImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(15)
            make.size.equalTo(36)
        }
        
        self.contentLab.snp.makeConstraints { make in
            make.left.equalTo(self.userHeadImageView.snp.right).offset(10)
            make.top.equalTo(self.userHeadImageView)
            make.right.equalToSuperview().offset(-10)
            make.height.greaterThanOrEqualTo(36)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(exitChatRoomObserverNotification(notification: )), name: NSNotification.Name.APPExitChatRoomNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(chatReadyToPlayObserverNotification(notification: )), name: NSNotification.Name.APPChatReadyPlayNotification, object: nil)
    }
    
    func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.APPExitChatRoomNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.APPChatReadyPlayNotification, object: nil)
    }
}

// MARK: Notification
@objc private extension LRChatBootChatCell {
    func exitChatRoomObserverNotification(notification: Notification) {
        DispatchQueue.main.async {
            self._text_animation?.stopAnimation()
            self._text_animation = nil
        }
    }
    
    func chatReadyToPlayObserverNotification(notification: Notification) {
        DispatchQueue.main.async {
            let animation = LRChatBootStringAppearOneByOneAnimation()
            animation.appearDuration = 0.01
            self.contentLab.animation_startAnimation(animation)
            animation.animationComplete = { [weak self] in
                self?._text_animation = nil
                self?.animationStop()
            }
            self._text_animation = animation
        }
    }
}
