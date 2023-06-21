//
//  LRChatBootChatViewController.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//
/*
 TODO
 2.检测语音播放时内存问题
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
    // iOS 15.0以上方法请求管理
    private var aiRequest: NSObject?
    // iOS 15.0 AIReplycell标记
    private var _AI_replay_mark: IndexPath?
    // iOS 15.0 AIReplycell标记
    private var _AI_replay_cell: UITableViewCell?
    // iOS 15.0 标记是否询问之前的问题
    private var _AI_ask_previous_question: Bool = false
    // iOS 15.0 缓存未读播报
    private var _cache_unread_broadcasts: [String] = []
    // iOS 15.0 未读播报终止符集合
    private let _set_unread_broadcast_terminators: [String] = [".","...","?","!","\n"]
    // iOS 15.0 未读播报
    private var _unread_broadcast: String = ""
    
    private weak var _inputBoxView: LRChatBootInputBoxView?
    private let CHAT_CELL_ID: String = "com.AI.chat.cell"
    private let AI_CHAT_CELL_ID: String = "com.AI.AIchat.cell"
    private let AI_CHAT_15_CELL_ID: String = "com.AI.AIchat15.cell"
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
    // 是否要设置预设问题
    private var _setDefaultQuestion: Bool?
    // 用户提问的问题组
    private var _questionsByUser: [[String: String]] = []
    // 是否收藏了主题
    private var _collection_topic: Bool = false
    // 当前话题下聊天总数
    private var _total_num_of_chat: Int = .zero
    
    init(topicModel: LRChatBootTopicModel?, showDefaultQuestion show: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        self._topicModel = topicModel
        self._setDefaultQuestion = show
        if let _total = topicModel?.totalNumberOfChatMessages {
            self._total_num_of_chat = _total
        }
        
        Log.debug("聊天记录 ID = \(topicModel?.chatRecordID ?? "") 总消息 = \(topicModel?.totalNumberOfChatMessages ?? .zero)")
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
        if let _show = self._setDefaultQuestion, _show, let _t_m = _topicModel?.topic {
            self._inputBoxView?.setDefaultTopic(topic: _t_m)
        }
        
        // 查看是否已经收藏
        if let _t_id = _topicModel?.topicID, let _ = LRChatBootTopicCollectionDB.shared.findChatTopicAccordingTopicID(topicID: _t_id) {
            // 重置收藏按钮状态
            self.navView.resetCollectionButtonStatus(isSelected: true)
        }
        
        // 从本地加载聊天记录
        self.loadChatRecordFromDB()
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
        self.chatTableView.register(LRChatBootAssistantCell.self, forCellReuseIdentifier: ASSISTANT_CHAT_CELL_ID)
        if #available(iOS 15.0, *) {
            self.chatTableView.register(LRChatBootAIChat15Cell.self, forCellReuseIdentifier: AI_CHAT_15_CELL_ID)
        } else {
            self.chatTableView.register(LRChatBootAIChatCell.self, forCellReuseIdentifier: AI_CHAT_CELL_ID)
        }
        
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
    
    func loadChatRecordFromDB() {
        guard let _r_id = self._topicModel?.chatRecordID, let _local_source = LRChatBootChatDB.shared.findChatRecordsBasedOnTopicID(topicID: _r_id) else {
            return
        }
        _chat_source.append(contentsOf: _local_source)
        _local_source.forEach { (chatModel: LRChatBootChatModel) in
            if chatModel.chatRole == .User {
                self._questionsByUser.append(chatModel.questionAskedByUser())
            }
        }
        self.chatTableView.reloadWithAnimation()
        self.chatTableView.scrollToRow(at: IndexPath(row: (_chat_source.count - 1), section: .zero), at: UITableView.ScrollPosition.top, animated: true)
    }
}

// MARK: Net Request
private extension LRChatBootChatViewController {
    /// iOS 15.0以上请求
    @available(iOS 15.0, *)
    func requestQuestionToRootUpiOS15(questionContext: [[String: String]], cellMark: IndexPath, askPreviousQuestions: Bool) {
        // 标记cell
        self._AI_replay_mark = cellMark
        self._AI_replay_cell = self.chatTableView.cellForRow(at: cellMark) as? LRChatBootAIChat15Cell
        // 标记是否询问之前的问题
        self._AI_ask_previous_question = askPreviousQuestions
        var _chunkedRequest: LRChatBootQuestionRequest?
        if self.aiRequest == nil {
            _chunkedRequest = LRChatBootQuestionRequest(replyDelegate: self)
            self.aiRequest = _chunkedRequest
        } else {
            _chunkedRequest = self.aiRequest as? LRChatBootQuestionRequest
        }
        _chunkedRequest?.receiveAIReplyByChunked(problems: questionContext)
    }
    
    /// iOS 15.0以下请求
    func requestQuestionToRoot(questionContext: [[String: String]], cellMark: IndexPath, requestComplete: @escaping (LRChatBootChatModel?) -> (Void)) {
        
        AIChatTarget().AIChatRequest(chatParams: questionContext) { [weak self] (rootReplys: [Any]?, error: Error?) in
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

            requestComplete(self?._chat_source[cellMark.row])
            
            self?.chatTableView.reloadRows(at: [cellMark], with: UITableView.RowAnimation.fade)
            self?.chatTableView.scrollToRow(at: cellMark, at: UITableView.ScrollPosition.top, animated: true)
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
        
        if _chat_model.chatRole == .AI {
            if #available(iOS 15.0, *) {
                if let cell = tableView.dequeueReusableCell(withIdentifier: AI_CHAT_15_CELL_ID, for: indexPath) as? LRChatBootAIChat15Cell {
                    cell.AIChatDelegate = self
                    _chat_cell = cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: AI_CHAT_CELL_ID, for: indexPath) as? LRChatBootAIChatCell {
                    cell.AIChatDelegate = self
                    _chat_cell = cell
                }
            }
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

// MARK: ChatBootAIChunkedReplyProtocol
extension LRChatBootChatViewController: ChatBootAIChunkedReplyProtocol {
    func AI_preparedToReceiveAIReply() {
        Log.debug("开始准备接收AI消息 ----------")
        guard let _mark = self._AI_replay_mark else {
            return
        }
        self._chat_source[_mark.row].isWaittingForAIReply = false
        self.chatTableView.reloadRows(at: [_mark], with: UITableView.RowAnimation.fade)
    }
    
    func AI_chunkedReply(reply: String) {
        guard let _mark = self._AI_replay_mark else {
            return
        }
        
        if #available(iOS 15.0, *), let _cell = self._AI_replay_cell as? LRChatBootAIChat15Cell {
            _cell.refreshAIReplyText(reply: reply)
        }
        
        // 拼接未读播报
        _unread_broadcast += reply
        for item in _set_unread_broadcast_terminators {
            if _unread_broadcast.hasSuffix(item) {
                Log.info("一句话结束 ----- \(_unread_broadcast)")
                // 一句话结束
                _cache_unread_broadcasts.append(_unread_broadcast)
                // 重置播报
                _unread_broadcast = ""
                break
            }
        }
        
        self.chatTableView.beginUpdates()
        self.chatTableView.reloadRows(at: [_mark], with: UITableView.RowAnimation.none)
        self.chatTableView.endUpdates()
#if DEBUG
#else
        self.speechSynthesizer.speechAIMessage(with: _cache_unread_broadcasts.removeFirst())
#endif
    }
    
    func AI_chunkedReplyEnd(error: Error?) {
        guard let _mark = self._AI_replay_mark else {
            return
        }
    
        if #available(iOS 15.0, *), let _cell = self._AI_replay_cell as? LRChatBootAIChat15Cell {
            self._chat_source[_mark.row].chatContent = error == nil ? _cell.AIReplayText : "AI reply error, try again"
        }
        self._chat_source[_mark.row].animationComplete = true
        self.chatTableView.reloadRows(at: [_mark], with: UITableView.RowAnimation.fade)
        self.chatTableView.scrollToRow(at: _mark, at: UITableView.ScrollPosition.bottom, animated: true)
        // 释放标记
        self._AI_replay_mark = nil
        self._AI_replay_cell = nil
        if !_unread_broadcast.isEmpty {
            _cache_unread_broadcasts.append(_unread_broadcast)
        }
        // 重置未读播报
        _unread_broadcast = ""
    }
}

// MARK: ChatBootAIChatProtocol
extension LRChatBootChatViewController: ChatBootAIChatProtocol {
    func AI_animationComplete(isEnd: Bool, cellMark: IndexPath?) {
        if let _indexPath = cellMark {
            self._chat_source[_indexPath.row].animationComplete = isEnd
            // 动画结束之后更新数据库
            if isEnd {
                // 查看聊天消息库内是否能找到此条消息
                if let _r_id = self._topicModel?.chatRecordID, var _dbChatModel = LRChatBootChatDB.shared.findChatMessageBasedOnTopicID(topicID: _r_id, chatSerialNumber: self._chat_source[_indexPath.row].chatSerialNumber) {
                    // 修改数据库中聊天内容
                    _dbChatModel.animationComplete = isEnd
                    if #available(iOS 15.0, *) {
                        _dbChatModel.chatContent = self._chat_source[_indexPath.row].chatContent
                        _dbChatModel.isWaittingForAIReply = self._chat_source[_indexPath.row].isWaittingForAIReply
                    }
                    LRChatBootChatDB.shared.updateChatModel(topicId: _r_id, updateChatModel: _dbChatModel)
                    Log.info("动画执行完毕 -- 更新消息 角色 = \(_dbChatModel.chatRole.rawValue) 消息编号 = \(_dbChatModel.chatSerialNumber)")
                } else {
                    Log.info("动画执行完毕 -- 更新消息 未在数据库中找到该消息, 消息编号 = \(self._chat_source[_indexPath.row].chatSerialNumber)")
                }
            }
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
            if #available(iOS 15.0, *) {
                self.requestQuestionToRootUpiOS15(questionContext: Array(_questionContext), cellMark: _p, askPreviousQuestions: true)
            } else {
                // 发起提问
                self.requestQuestionToRoot(questionContext: Array(_questionContext), cellMark: _p) { [weak self] (chatModel: LRChatBootChatModel?) in
                    guard let _chat = chatModel else {
                        return
                    }
                    // 查看聊天消息库内是否能找到此条消息
                    if let _r_id = self?._topicModel?.chatRecordID, var _dbChatModel = LRChatBootChatDB.shared.findChatMessageBasedOnTopicID(topicID: _r_id, chatSerialNumber: _chat.chatSerialNumber) {
                        // 修改数据库中聊天内容
                        _dbChatModel.chatContent = _chat.chatContent
                        _dbChatModel.isWaittingForAIReply = _chat.isWaittingForAIReply
                        LRChatBootChatDB.shared.updateChatModel(topicId: _r_id, updateChatModel: _dbChatModel)
                        Log.info("重新询问AI已有的问题 -- 更新消息 角色 = \(_dbChatModel.chatRole.rawValue) 消息编号 = \(_dbChatModel.chatSerialNumber)")
                    } else {
                        Log.info("重新询问AI已有的问题 未在数据库中找到该消息, 消息编号 = \(_chat.chatSerialNumber)")
                    }
                }
            }
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
                // iOS 15.0 系统以上需要停止收流
                if #available(iOS 15.0, *), let _request = self?.aiRequest as? LRChatBootQuestionRequest {
                    _request.stopAIReplyRequest()
                    self?.aiRequest = nil
                }
                
                // 更新聊天总数
                if let _chat_id = self?._topicModel?.chatRecordID, var _db_m = LRChatBootChatTopicDB.shared.findChatTopicAccordingTopicID(chatRecordID: _chat_id) {
                    if let _total = self?._total_num_of_chat, _total != .zero {
                        _db_m.totalNumberOfChatMessages = _total
                        LRChatBootChatTopicDB.shared.updateTopicTotalNumberOfChatMessages(topicModel: _db_m)
                        Log.debug("更新聊天总数 ----------- \(_total) 条消息")
                    }
                }
                
                // 更新最后一条聊天消息状态
                if let _chat_id = self?._topicModel?.chatRecordID, let _num = self?._total_num_of_chat, var _chat = LRChatBootChatDB.shared.findChatMessageBasedOnTopicID(topicID: _chat_id, chatSerialNumber: _num) {
                    _chat.animationComplete = true
                    _chat.isWaittingForAIReply = false
                    if #available(iOS 15.0, *), let _cell = self?._AI_replay_cell as? LRChatBootAIChat15Cell {
                        _chat.chatContent = _cell.AIReplayText
                    }
                    LRChatBootChatDB.shared.updateChatModel(topicId: _chat_id, updateChatModel: _chat)
                    Log.info("退出聊天界面, 更新数据库动画未执行完毕或者还未收到回复的消息 === 消息编号 = \(_chat.chatSerialNumber)")
                }
                
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
        
        let _can_send = _can_send_question && !_is_waitting_AI_reply
        if _can_send {
            // 清空语音未读博报
            _cache_unread_broadcasts.removeAll()
            // 重置未读播报
            _unread_broadcast = ""
            // 停止播放语言
            self.speechSynthesizer.stopSpeaking()
        }
        return _can_send
    }
    
    func AI_sendQuestion(question: String) {
        if self._chat_source.isEmpty && self._topicModel == nil {
            // 根据用户提问的问题生成一个话题Model
            self._topicModel = LRChatBootTopicModel.generatedBasedOnUserInput(topic: question)
        }
        
        // 消息数叠加
        _total_num_of_chat += 1
        
        // 提问信息
        var _chatModel: LRChatBootChatModel = LRChatBootChatModel()
        _chatModel.chatContent = question
        _chatModel.chatRole = AIChatRole.User
        _chatModel.chatSerialNumber = _total_num_of_chat
        _chat_source.append(_chatModel)
        _questionsByUser.append(["content": question, "role": _chatModel.chatRole.rawValue])
        let _askIndex: IndexPath = IndexPath(row: (_chat_source.count - 1), section: .zero)

        // 消息数叠加
        _total_num_of_chat += 1
        
        // AI回答消息预设
        var _AIChatModel: LRChatBootChatModel = LRChatBootChatModel()
        _AIChatModel.chatRole = AIChatRole.AI
        _AIChatModel.askQuestion = question
        _AIChatModel.chatSerialNumber = _total_num_of_chat
        _chat_source.append(_AIChatModel)
        let _replyIndex: IndexPath = IndexPath(row: (_chat_source.count - 1), section: .zero)
        self.chatTableView.insertRows(at: [_askIndex, _replyIndex], with: UITableView.RowAnimation.fade)
        self.chatTableView.scrollToRow(at: _replyIndex, at: UITableView.ScrollPosition.top, animated: true)
        
        // 请求接口
        if #available(iOS 15.0, *) {
            self.requestQuestionToRootUpiOS15(questionContext: self._questionsByUser, cellMark: _replyIndex, askPreviousQuestions: false)
        } else {
            self.requestQuestionToRoot(questionContext: self._questionsByUser, cellMark: _replyIndex) { [weak self] (chatModel: LRChatBootChatModel?) in
                guard let _chat = chatModel, let _recordID = self?._topicModel?.chatRecordID else {
                    return
                }
                Log.debug("收到AI回复 角色 = \(_chat.chatRole.rawValue) 单条插入 消息编号 = \(_chat.chatSerialNumber)")
                LRChatBootChatDB.shared.insertChatRecord(chat: _chat, topicID: _recordID)
            }
        }
        
        // 存库处理
        guard var _t_m = self._topicModel else {
            return
        }
        
        /*
         聊天记录入库规则:
         Now:
         1.发送一条消息入库一条消息
         优化:
         1.判断是否达到了规定的上限值,若达到,截取上限值的一半,存入数据库
         2.用户退出界面的时候,存储容器内剩余的聊天记录
         */
        // 用户不是从预设问题进入, 提问问题1条以上即可执行入库/用户从预设问题进入,需要提问2条以上问题才可以执行入库
        if (_t_m.generatedBasedOnUserInput && _questionsByUser.count >= 1) ||
            (!_t_m.generatedBasedOnUserInput && _questionsByUser.count >= 2) {
            if _t_m.chatRecordID == nil {
                // 创建聊天记录ID
                _t_m.chatRecordID = Date().millisecondTimestampStringValue
                // 存储话题到DB
                LRChatBootChatTopicDB.shared.insertChatTopic(chatTopic: _t_m)
                // 创建与话题对应的聊天记录表
                LRChatBootChatDB.shared.createChatRecordTable(topicId: _t_m.chatRecordID ?? "")
                if #available(iOS 15.0, *) {
                    // 存储消息
                    LRChatBootChatDB.shared.batchInsertChatRecords(chats: self._chat_source, topicID: _t_m.chatRecordID ?? "")
                } else {
                    // 存储消息
                    LRChatBootChatDB.shared.batchInsertChatRecords(chats: Array(self._chat_source.prefix(self._chat_source.count - 1)), topicID: _t_m.chatRecordID ?? "")
                }
                self._topicModel = _t_m
                Log.debug("发送消息 批量插入数据库 消息数目 = \(self._chat_source.count)")
            } else {
                // 单条插入数据库
                LRChatBootChatDB.shared.insertChatRecord(chat: _chatModel, topicID: _t_m.chatRecordID ?? "")
                Log.debug("发送消息 角色 = \(_chatModel.chatRole.rawValue) 单条插入 消息编号 = \(_chatModel.chatSerialNumber)")
                if #available(iOS 15.0, *) {
                    Log.debug("插入AI空白回复 角色 = \(_AIChatModel.chatRole.rawValue) 单条插入 消息编号 = \(_AIChatModel.chatSerialNumber)")
                    LRChatBootChatDB.shared.insertChatRecord(chat: _AIChatModel, topicID: self._topicModel?.chatRecordID ?? "")
                }
            }
        }
    }
}

// MARK: ChatBootSpeechProtocol
extension LRChatBootChatViewController: ChatBootSpeechProtocol {
    func AI_speechStart() {
        NotificationCenter.default.post(name: NSNotification.Name.APPChatReadyPlayNotification, object: nil)
    }
    
    func AI_speechEnd() {
        if self._cache_unread_broadcasts.isEmpty {
            self.speechSynthesizer.stopSpeaking()
            Log.info("语言播放完毕 ------------")
            return
        }
        
        self.speechSynthesizer.speechAIMessage(with: _cache_unread_broadcasts.removeFirst())
    }
    
    func AI_mutePlayback() -> Bool {
        return LRChatBootChatCache.readSpeechMute()
    }
}
