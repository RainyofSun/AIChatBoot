//
//  LRChatBootChatViewController.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//
/*
 TODO
 2.检测语音播放时内存问题
 4.订阅页面UI
 6.数据库存储处理
 */
import UIKit
import Toast_Swift

class LRChatBootChatViewController: LRChatBootBaseViewController, HideNavigationBarProtocol {
    
    private lazy var navView: LRChatBootChatNavView = {
        return LRChatBootChatNavView(frame: CGRectZero)
    }()
    
    private lazy var chatTableView: LRChatBootChatTableView = {
        return LRChatBootChatTableView(frame: CGRectZero, style: UITableView.Style.plain)
    }()
    
    private lazy var speechSynthesizer: LRChatBootSpeechSynthesizer = LRChatBootSpeechSynthesizer()
    
    private weak var _inputBoxView: LRChatBootInputBoxView?
    private let CHAT_CELL_ID: String = "com.AI.chat.cell"
    private let AI_CHAT_CELL_ID: String = "com.AI.AIchat.cell"
    private let ASSISTANT_CHAT_CELL_ID: String = "com.AI.assistant.cell"
    
    private var _chat_source: [LRChatBootChatModel] = []
    // 是否可以发送新问题
    private var _can_send_question: Bool = true
    // 外界进入时携带的话题
    private var _topicModel: LRChatBootTopicModel?
    
    init(topicModel: LRChatBootTopicModel) {
        super.init(nibName: nil, bundle: nil)
        self._topicModel = topicModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadChatViews()
        layoutChatViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _t_m = _topicModel?.topic {
            self._inputBoxView?.setDefaultTopic(topic: _t_m)
        }
    }
    
    override func willEnterBackground(notification: Notification) {
        super.willEnterBackground(notification: notification)
        self.speechSynthesizer.stopSpeaking()
    }
    
    override func shouldBePopped(_ navigationController: UINavigationController) -> Bool {
        self.AI_chatBack()
        return false
    }
    
    deinit {
        NotificationCenter.default.post(name: NSNotification.Name.APPExitChatRoomNotification, object: nil)
        self.speechSynthesizer.free()
    }
}

// MARK: Private Methods
private extension LRChatBootChatViewController {
    func loadChatViews() {
        
        self.navView.resetMuteButtonStatus(isSelected: LRChatBootChatCache.readSpeechMute())
        self.navView.navDelegate = self
        
        self.chatTableView.resignFirstResponderHandler = { [weak self] in
            self?._inputBoxView?.resignInputBoxFirstResponder()
        }
        
        self.speechSynthesizer.speechDelegate = self
        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self
        self.chatTableView.register(LRChatBootChatCell.self, forCellReuseIdentifier: CHAT_CELL_ID)
        self.chatTableView.register(LRChatBootAIChatCell.self, forCellReuseIdentifier: AI_CHAT_CELL_ID)
        self.chatTableView.register(LRChatBootAssistantCell.self, forCellReuseIdentifier: ASSISTANT_CHAT_CELL_ID)
        
        self.view.addSubview(self.navView)
        self.view.addSubview(self.chatTableView)
        self._inputBoxView = buildChatInputBoxView(canInput: true, inputDelegate: self)
    }
    
    func layoutChatViews() {
        self.navView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(statusBarHeight())
            make.horizontalEdges.equalToSuperview()
        }
        
        self.chatTableView.snp.makeConstraints { make in
            make.top.equalTo(self.navView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().offset(-90)
        }
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension LRChatBootChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _chat_source.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _chat_model = _chat_source[indexPath.row]
        var _chat_cell: LRChatBootChatCell?
        if _chat_model.chatRole == .User, let cell = tableView.dequeueReusableCell(withIdentifier: CHAT_CELL_ID, for: indexPath) as? LRChatBootChatCell {
            _chat_cell = cell
        }
        
        if _chat_model.chatRole == .AI, let cell = tableView.dequeueReusableCell(withIdentifier: AI_CHAT_CELL_ID, for: indexPath) as? LRChatBootAIChatCell {
            cell.AIChatDelegate = self
            _chat_cell = cell
        }
        
        if _chat_model.chatRole == .Assistant, let cell = tableView.dequeueReusableCell(withIdentifier: ASSISTANT_CHAT_CELL_ID, for: indexPath) as? LRChatBootAssistantCell {
            _chat_cell = cell
        }
        
        _chat_cell?.chatAnimationDelegate = self
        _chat_cell?.cellMark = indexPath
        _chat_cell?.reloadChatCellSource(chatModel: _chat_model)
        
        return _chat_cell ?? UITableViewCell()
    }
}

// MARK: ChatBootAIChatProtocol
extension LRChatBootChatViewController: ChatBootAIChatProtocol {
    func AI_animationComplete(isEnd: Bool, cellMark: IndexPath?) {
        if let _indexPath = cellMark {
            self._chat_source[_indexPath.row].animationComplete = isEnd
        }
        _can_send_question = isEnd
    }
    
    func AI_refreshAIReply(cellMark: IndexPath?) {
        guard let _p = cellMark else {
            return
        }
        self._chat_source[_p.row].chatContent = "开始刷新新的内容开始刷新新的内容开始刷新新的内容开始刷新新的内容"
        // TODO: 模拟网络延迟
        delay(3) {
            self.chatTableView.reloadRows(at: [_p], with: UITableView.RowAnimation.fade)
        }
    }
    
    func AI_copyAIReply(replyContent: String) {
        UIPasteboard.general.string = replyContent
        self.view.makeToast(LRLocalizableManager.localValue("Copy Successfully"))
    }
    
    func AI_shareReplyContent(content: String) {
        self.systemShare(title: content)
    }
}

// MARK: ChatBootChatNavProtocol
extension LRChatBootChatViewController: ChatBootChatNavProtocol {
    func AI_chatBack() {
        self._inputBoxView?.resignInputBoxFirstResponder()
        self.showExitChatRoomAlert { [weak self] isOK in
            if isOK {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func AI_ChatMute(isMute: Bool) {
        LRChatBootChatCache.saveSpeechMute(isMute: isMute)
    }
    
    func AI_collectTopic(animationView: UIButton) {
        UIView.animate(withDuration: APPAnimationDurationTime) {
            animationView.transform = CGAffineTransform.init(scaleX: 0.3, y: 0.3)
        } completion: { _ in
            UIView.animate(withDuration: APPAnimationDurationTime) {
                animationView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            } completion: { _ in
                animationView.transform = CGAffineTransform.identity
                animationView.isSelected = !animationView.isSelected
            }
        }
    }
}

// MARK: ChatBootInputBoxProtocol
extension LRChatBootChatViewController: ChatBootInputBoxProtocol {
    func AI_canSendNewQuestion() -> Bool {
        if !_can_send_question {
            self.view.makeToast(LRLocalizableManager.localValue("chatTip"))
        }
        return _can_send_question
    }
    
    func AI_sendQuestion(question: String) {
        Log.debug("输入的问题 ------- \(question)")
        var _chatModel: LRChatBootChatModel = LRChatBootChatModel()
        _chatModel.chatContent = question
        _chatModel.chatRole = .AI
        _chat_source.append(_chatModel)
        let _insertIndex: IndexPath = IndexPath(row: (_chat_source.count - 1), section: .zero)
        self.chatTableView.insertRows(at: [_insertIndex], with: UITableView.RowAnimation.fade)
        self.chatTableView.scrollToRow(at: _insertIndex, at: UITableView.ScrollPosition.top, animated: true)
#if DEBUG
#else
        self.speechSynthesizer.speechAIMessage(with: question)
#endif
    }
}

// MARK: ChatBootSpeechProtocol
extension LRChatBootChatViewController: ChatBootSpeechProtocol {
    func AI_speechStart() {
        Log.debug("----- 开始播放语音 ------")
        NotificationCenter.default.post(name: NSNotification.Name.APPChatReadyPlayNotification, object: nil)
    }
    
    func AI_mutePlayback() -> Bool {
        return LRChatBootChatCache.readSpeechMute()
    }
}
