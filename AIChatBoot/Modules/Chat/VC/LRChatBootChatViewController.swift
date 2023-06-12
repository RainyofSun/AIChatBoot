//
//  LRChatBootChatViewController.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//
/*
 TODO
 2.检测语音播放时内存问题
 6.数据库存储处理
 */
import UIKit
import Toast_Swift

class LRChatBootChatViewController: LRChatBootBaseViewController, HideNavigationBarProtocol {
    
    // 外界刷新收藏数据
    open var refreshCollectionDataClosure: (() -> Void)?
    
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
    // 最大聊天内容承载(界面最大显示消息条数,超出后自动截取内容最大承载的1/2,存入数据库)
    private let MAX_CHAT_COUNT: Int = 20
    // 聊天内容数据
    private var _chat_source: [LRChatBootChatModel] = []
    // 是否可以发送新问题
    private var _can_send_question: Bool = true
    // 是否在等待AI回答
    private var _is_waitting_AI_reply: Bool = false
    // 外界进入时携带的话题
    private var _topicModel: LRChatBootTopicModel?
    // 用户提问的问题组
    private var _questionsByUser: [[String: String]] = []
    // 是否收藏了主题
    private var _collection_topic: Bool = false
    
    init(topicModel: LRChatBootTopicModel?) {
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
        
        // 查看是否已经收藏
        if let _t_id = _topicModel?.topicID, let _ = LRChatBootTopicCollectionDB.shared.findChatTopicAccordingTopicID(topicID: _t_id) {
            // 重置收藏按钮状态
            self.navView.resetCollectionButtonStatus(isSelected: true)
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
        self.refreshCollectionDataClosure?()
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

// MARK: Net Request
private extension LRChatBootChatViewController {
    func requestQuestionToRoot(questionContext: [[String: String]], cellMark: IndexPath) {
        
        AIChatQuestionTarget().AIChatRequest(chatParams: questionContext) { [weak self] (rootReplys: [Any]?, error: Error?) in
            var _chatContent: String = ""
            if error != nil {
                _chatContent = LRLocalizableManager.localValue("chatError")
            } else {
                if let _replys = rootReplys as? [[String: Any]] {
                    _replys.forEach { (item: [String : Any]) in
                        if let _content = item["message"] as? [String: String], let _reply = _content["content"] {
                            _chatContent += _reply
                        }
                    }
                }
            }
            
            self?._chat_source[cellMark.row].chatContent = _chatContent
            self?._chat_source[cellMark.row].isWaittingForAIReply = false

            self?.chatTableView.reloadRows(at: [cellMark], with: UITableView.RowAnimation.fade)
            self?.chatTableView.scrollToRow(at: cellMark, at: UITableView.ScrollPosition.top, animated: true)
            self?.speechSynthesizer.speechAIMessage(with: _chatContent)
#if DEBUG
#else
            self?.speechSynthesizer.speechAIMessage(with: _chatContent)
#endif
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
    
    func AI_indicatorAnimationComplete(isWaitting: Bool, cellMark: IndexPath?) {
        self._is_waitting_AI_reply = isWaitting
    }
    
    func AI_refreshAIReply(cellMark: IndexPath?) {
        guard let _p = cellMark else {
            return
        }
        
        self._chat_source[_p.row].isWaittingForAIReply = true
        self._chat_source[_p.row].animationComplete = false
        self._chat_source[_p.row].chatContent = ""
        
        self.chatTableView.reloadRows(at: [_p], with: UITableView.RowAnimation.fade)
        
        // 截取问题上下文
        if let _lastIndex = self._questionsByUser.lastIndex(where: {$0["content"] == self._chat_source[_p.row].askQuestion}) {
            let _questionContext: ArraySlice<[String: String]> = self._questionsByUser[0..._lastIndex]
            // 发起提问
            self.requestQuestionToRoot(questionContext: Array(_questionContext), cellMark: _p)
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
        if self._topicModel == nil {
            Log.info("聊天消息为空,不可以进行话题收藏 --------------")
            self.view.makeToast(LRLocalizableManager.localValue("chatCollectionTip"))
            return
        }
        UIView.animate(withDuration: APPAnimationDurationTime) {
            animationView.transform = CGAffineTransform.init(scaleX: 0.3, y: 0.3)
        } completion: { _ in
            UIView.animate(withDuration: APPAnimationDurationTime) {
                animationView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            } completion: { _ in
                animationView.transform = CGAffineTransform.identity
                animationView.isSelected = !animationView.isSelected
                guard let _topicModel = self._topicModel  else {
                    return
                }
                if animationView.isSelected {
                    // 收藏话题到数据库
                    LRChatBootTopicCollectionDB.shared.insertChatTopic(chatTopic: _topicModel)
                } else {
                    if let _dbModel = LRChatBootTopicCollectionDB.shared.findChatTopicAccordingTopicID(topicID: _topicModel.topicID ?? "") {
                        // 数据库中删除已收藏的话题
                        LRChatBootTopicCollectionDB.shared.deleteChatTopic(chatTopicDBID: _dbModel.identifier ?? .zero)
                    } else {
                        Log.error("收藏数据库中未找到此话题 ====== \(_topicModel.topicID ?? "")")
                    }
                }
            }
        }
    }
}

// MARK: ChatBootInputBoxProtocol
extension LRChatBootChatViewController: ChatBootInputBoxProtocol {
    func AI_canSendNewQuestion() -> Bool {

        // 等待AI回答过程中或者文字动画未结束不允许再次发送问题
        if !_can_send_question || self._is_waitting_AI_reply {
            self.view.makeToast(LRLocalizableManager.localValue("chatTip"))
        }
        
        return _can_send_question && !_is_waitting_AI_reply
    }
    
    func AI_sendQuestion(question: String) {
        if self._chat_source.isEmpty && self._topicModel == nil {
            // 根据用户提问的问题生成一个话题Model
            self._topicModel = LRChatBootTopicModel.generatedBasedOnUserInput(topic: question)
        }
        
        // 提问信息
        var _chatModel: LRChatBootChatModel = LRChatBootChatModel()
        _chatModel.chatContent = question
        _chatModel.chatRole = AIChatRole.User
        _chat_source.append(_chatModel)
        _questionsByUser.append(["content": question, "role": _chatModel.chatRole.rawValue])
        let _askIndex: IndexPath = IndexPath(row: (_chat_source.count - 1), section: .zero)
        
        // AI回答消息预设
        var _AIChatModel: LRChatBootChatModel = LRChatBootChatModel()
        _AIChatModel.chatRole = AIChatRole.AI
        _AIChatModel.askQuestion = question
        _chat_source.append(_AIChatModel)
        let _replyIndex: IndexPath = IndexPath(row: (_chat_source.count - 1), section: .zero)
        self.chatTableView.insertRows(at: [_askIndex, _replyIndex], with: UITableView.RowAnimation.fade)
        self.chatTableView.scrollToRow(at: _replyIndex, at: UITableView.ScrollPosition.top, animated: true)
        
        // 请求接口
        self.requestQuestionToRoot(questionContext: self._questionsByUser, cellMark: _replyIndex)
//        // 存库处理
//        if self._chat_source.count >= MAX_CHAT_COUNT {
//            // 截取最大承载的1/2
//            let _subChatContent: [LRChatBootChatModel] = Array(self._chat_source.prefix(MAX_CHAT_COUNT/2))
//            guard var _topicModel = self._topicModel else {
//                return
//            }
//            if _topicModel.chatRecordID == nil {
//                // 创建聊天记录ID
//                _topicModel.chatRecordID = Date().millisecondTimestampStringValue
//                // 存储话题到DB
//                LRChatBootChatTopicDB.shared.insertChatTopic(chatTopic: _topicModel)
//            }
//            // 创建与话题对应的聊天记录表
//            LRChatBootChatDB.shared.createChatRecordTable(topicId: _topicModel.chatRecordID ?? "")
//            // 批量插入聊天记录
//            LRChatBootChatDB.shared.batchInsertChatRecords(chats: _subChatContent, topicID: _topicModel.chatRecordID ?? "")
//            self.chatTableView.reloadData()
//        } else {
//            self.chatTableView.insertRows(at: [_askIndex, _replyIndex], with: UITableView.RowAnimation.fade)
//            self.chatTableView.scrollToRow(at: _replyIndex, at: UITableView.ScrollPosition.top, animated: true)
//        }
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
