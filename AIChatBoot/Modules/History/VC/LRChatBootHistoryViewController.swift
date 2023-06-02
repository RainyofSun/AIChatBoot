//
//  LRChatBootHistoryViewController.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//

import UIKit
import Toast_Swift

class LRChatBootHistoryViewController: UIViewController, HideNavigationBarProtocol {

    private lazy var navView: LRChatBootCustomNavView = {
        return LRChatBootCustomNavView(frame: CGRectZero, navStyle: LRChatBootCustomNavView.CustomNavigationType.History)
    }()
    
    private lazy var editView: LRChatBootChatRecordEditView = {
        return LRChatBootChatRecordEditView(frame: CGRectZero)
    }()
    
    private lazy var recordTableView: UITableView = {
        let view = UITableView(frame: CGRectZero, style: UITableView.Style.plain)
        view.separatorStyle = .none
        view.backgroundColor = .clear
        view.allowsMultipleSelectionDuringEditing = true
        return view
    }()
    
    private lazy var deleteBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setTitle(LRLocalizableManager.localValue("Delete"), for: UIControl.State.normal)
        btn.setTitle(LRLocalizableManager.localValue("Delete"), for: UIControl.State.highlighted)
        btn.setTitleColor(UIColor(hexString: "#AAAAAA"), for: UIControl.State.normal)
        btn.setTitleColor(UIColor(hexString: "#AAAAAA"), for: UIControl.State.highlighted)
        btn.backgroundColor = UIColor(hexString: "#1A1A1A")
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.cornerRadius = 28
        btn.alpha = .zero
        return btn
    }()
    
    private let CHAT_RECORD_CELL_ID = "com.AI.chatRecord.cell"
    private var _chat_record_source: [LRChatBootTopicModel]?
    private var _chat_record_delete: [LRChatBootTopicModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadHistoryViews()
        layoutHistoryViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        testData()
    }
    
    // MARK: Public Methods
    public func reloadChatRecords(data: [LRChatBootTopicModel]) {
        _chat_record_source = data
        self.recordTableView.reloadData()
    }
}

// MARK: Private Methods
private extension LRChatBootHistoryViewController {
    func loadHistoryViews() {
        self.view.backgroundColor = MainBGColor
        
        self.navView.navDelegate = self
        self.editView.editDelegate = self
        self.recordTableView.delegate = self
        self.recordTableView.dataSource = self
        self.recordTableView.emptyDataSetSource = self
        self.recordTableView.emptyDataSetDelegate = self
        self.recordTableView.register(LRChatBootChatRecordCell.self, forCellReuseIdentifier: CHAT_RECORD_CELL_ID)
        self.deleteBtn.addTarget(self, action: #selector(deleteChatRecord(sender: )), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(self.navView)
        self.view.addSubview(self.editView)
        self.view.addSubview(self.recordTableView)
        self.view.addSubview(self.deleteBtn)
    }
    
    func layoutHistoryViews() {
        self.navView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview().offset(statusBarHeight())
        }
        
        self.editView.snp.makeConstraints { make in
            make.left.equalTo(self.navView.snp.right)
            make.centerY.width.equalTo(self.navView)
        }
        
        self.recordTableView.snp.makeConstraints { make in
            make.top.equalTo(self.navView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        self.deleteBtn.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.horizontalEdges.equalToSuperview().inset(42)
            make.bottom.equalTo(self.recordTableView.snp.bottom).offset(-10)
        }
    }
    
    // 删除选中的记录
    func deleteChatRecord(tableView: UITableView) {
        guard !self._chat_record_delete.isEmpty, let _deleteIndexPaths = tableView.indexPathsForSelectedRows else {
            return
        }
        
        self._chat_record_delete.enumerated().forEach { (index: Int, item: LRChatBootTopicModel) in
            self._chat_record_source?.removeAll(where: {$0.topic == item.topic})
        }
        
        tableView.deleteRows(at: _deleteIndexPaths, with: UITableView.RowAnimation.fade)
        if let _isEmpty = self._chat_record_source?.isEmpty, _isEmpty {
            self.AI_cancelSelection()
            self.navView.canEdit = false
            tableView.reloadEmptyDataSet()
        }
        self._chat_record_delete.removeAll()
        self.deleteBtn.backgroundColor = UIColor(hexString: "#1A1A1A")
    }
    
    // TODO: Test Data
    func testData() {
        var _source: [LRChatBootTopicModel] = []
        for index in 0..<10 {
            var _model = LRChatBootTopicModel()
            _model.topic = "Acts as a form generator. Users are free to fill the catalog and conten…"
            _model.hotTopics = "993390"
            _model.topicClassification = "Education_____\(index)"
            _model.topicClassificationID = "id_____\(index)"
            _source.append(_model)
        }
        self.reloadChatRecords(data: _source)
        self.navView.canEdit = true
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension LRChatBootHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _chat_record_source?.count ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CHAT_RECORD_CELL_ID, for: indexPath) as? LRChatBootChatRecordCell else {
            return UITableViewCell()
        }
        if let _model = _chat_record_source?[indexPath.row] {
            cell.reloadChatRecordCellSource(title: _model.topic ?? "", time: _model.chatTime)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle(rawValue: UITableViewCell.EditingStyle.delete.rawValue | UITableViewCell.EditingStyle.insert.rawValue)!
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextualAction = UIContextualAction.init(style: UIContextualAction.Style.destructive, title: nil) { [weak self] (contextualAction, view, completionHandler) in
            let alert: LRChatBootAlertView = LRChatBootAlertView(frame: CGRectZero)
            alert.setAlertTitle(title: LRLocalizableManager.localValue("historyDeleteAlertTitle"), alertSubTitle: LRLocalizableManager.localValue("historyDeleteAlertContent"), alertImage: "alert_icon_history")
            self?.view.addSubview(alert)
            alert.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            alert.showAlert { [weak self] isOK in
                if isOK {
                    self?._chat_record_source?.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                }
                completionHandler(isOK)
            }
        }
        contextualAction.image = UIImage(named: "history_icon_delete")
        let config = UISwipeActionsConfiguration.init(actions: [contextualAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        for subView in tableView.subviews {
            if NSStringFromClass(subView.classForCoder) == "_UITableViewCellSwipeContainerView" {
                for sub in subView.subviews {
                    if NSStringFromClass(sub.classForCoder) == "UISwipeActionPullView" {
                        if let deleteBtn: UIButton = sub.subviews.last as? UIButton  {
                            // TODO: Frame 改不动
                            let view = UIView(frame: deleteBtn.bounds)
                            view.backgroundColor = UIColor(hexString: "#D61522")
                            deleteBtn.insertSubview(view, belowSubview: deleteBtn.imageView!)
                            deleteBtn.layer.cornerRadius = 20
                            deleteBtn.clipsToBounds = true
                            sub.layer.cornerRadius = 20
                            sub.clipsToBounds = true
                            sub.backgroundColor = view.backgroundColor
                            break
                        }
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self._chat_record_source?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard tableView.isEditing, let _selectedIndexPaths = tableView.indexPathsForSelectedRows, let _source = self._chat_record_source else {
            if let _topic_model = _chat_record_source?[indexPath.row] {
                // 非编辑态时进入聊天
                self.navigationController?.pushViewController(LRChatBootChatViewController(topicModel: _topic_model), animated: true)
            }
            return
        }
        self.editView.resetSelectedAllButtonStatus(isSelected: (_selectedIndexPaths.count == _source.count))
        let _selected_model = _source[indexPath.row]
        if self._chat_record_delete.contains(where: {$0.topic == _selected_model.topic}) {
            return
        }
        self._chat_record_delete.append(_selected_model)
        self.deleteBtn.backgroundColor = APPThemeColor
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let _selectedIndexPaths = tableView.indexPathsForSelectedRows, let _source = self._chat_record_source else {
            return
        }
        
        self.editView.resetSelectedAllButtonStatus(isSelected: (_selectedIndexPaths.count == _source.count))
        let _selected_model = _source[indexPath.row]
        if let _index = self._chat_record_delete.firstIndex(where: {$0.topic == _selected_model.topic}) {
            self._chat_record_delete.remove(at: _index)
        }
        
        if self._chat_record_delete.isEmpty {
            self.deleteBtn.backgroundColor = UIColor(hexString: "#1A1A1A")
        }
    }
}

// MARK: EmptyDataSetDelegate
extension LRChatBootHistoryViewController: EmptyDataSetDelegate, EmptyDataSetSource {
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        let emptyView = LRChatBootEmptyView.init(frame: CGRectZero)
        emptyView.placeholderImage(UIImage(named: "history_icon_empty")!, placeholderText: LRLocalizableManager.localValue("historyEmpty"))
        scrollView.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return emptyView
    }
}

// MARK: CustomNavProtocol
extension LRChatBootHistoryViewController: CustomNavProtocol {
    func AI_clickNavOperation() {
        UIView.animate(withDuration: APPAnimationDurationTime, delay: .zero, options: UIView.AnimationOptions.curveEaseInOut) {
            self.navView.snp.remakeConstraints { make in
                make.width.equalToSuperview()
                make.right.equalTo(self.view.snp.left)
                make.top.equalToSuperview().offset(self.statusBarHeight())
            }
            self.deleteBtn.alpha = 1
            self.view.layoutIfNeeded()
        }
        self.recordTableView.setEditing(true, animated: true)
    }
}

// MARK: ChatRecordEditProtocol
extension LRChatBootHistoryViewController: ChatRecordEditProtocol {
    func AI_selectedAll(isSelectedAll: Bool) {
        guard self.recordTableView.isEditing else {
            return
        }
        
        let _count = self._chat_record_source?.count ?? .zero
        for index in 0..<_count {
            if isSelectedAll {
                self.recordTableView.selectRow(at: IndexPath(row: index, section: .zero), animated: true, scrollPosition: UITableView.ScrollPosition.none)
            } else {
                self.recordTableView.deselectRow(at: IndexPath(row: index, section: .zero), animated: true)
            }
        }
        
        isSelectedAll ? self._chat_record_delete.append(contentsOf: self._chat_record_source!) : self._chat_record_delete.removeAll()
        self.deleteBtn.backgroundColor = isSelectedAll ? APPThemeColor : UIColor(hexString: "#1A1A1A")
    }
    
    func AI_cancelSelection() {
        UIView.animate(withDuration: APPAnimationDurationTime, delay: .zero, options: UIView.AnimationOptions.curveEaseInOut) {
            self.navView.snp.remakeConstraints { make in
                make.horizontalEdges.equalToSuperview()
                make.top.equalToSuperview().offset(self.statusBarHeight())
            }
            self.deleteBtn.alpha = .zero
            self.view.layoutIfNeeded()
        }
        self.recordTableView.setEditing(false, animated: true)
        self.editView.resetSelectedAllButtonStatus(isSelected: false)
    }
}

// MARK: Target
@objc private extension LRChatBootHistoryViewController {
    func deleteChatRecord(sender: UIButton) {
        guard !self._chat_record_delete.isEmpty else {
            self.view.makeToast(LRLocalizableManager.localValue("historyTip"))
            return
        }
        
        let alert: LRChatBootAlertView = LRChatBootAlertView(frame: CGRectZero)
        alert.setAlertTitle(title: LRLocalizableManager.localValue("historyDeleteAlertTitle"), alertSubTitle: LRLocalizableManager.localValue("historyDeleteAlertContent"), alertImage: "alert_icon_history")
        self.view.addSubview(alert)
        alert.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        alert.showAlert { [weak self] isOK in
            if isOK {
                self?.deleteChatRecord(tableView: self!.recordTableView)
            }
        }
    }
}
