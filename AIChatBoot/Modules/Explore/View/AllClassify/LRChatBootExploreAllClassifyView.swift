//
//  LRChatBootExploreAllClassifyView.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit

class LRChatBootExploreAllClassifyView: UIView {

    open weak var topicDelegate: ChatBootTopicCellProtocol?
    
    private lazy var allClassifyTableView: UITableView = {
        let view = UITableView(frame: CGRectZero, style: UITableView.Style.plain)
        view.separatorStyle = .none
        view.backgroundColor = .clear
        return view
    }()
    
    private let ALL_CLASSIFY_CELL_ID: String = "com.explore.allClassifyCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadAllClassifyViews()
        layoutAllClassifyViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
}

// MARK: Private Methods
private extension LRChatBootExploreAllClassifyView {
    func loadAllClassifyViews() {
        
        self.allClassifyTableView.delegate = self
        self.allClassifyTableView.dataSource = self
        
        self.allClassifyTableView.register(LRChatBootExploreAllClassifyCell.self, forCellReuseIdentifier: ALL_CLASSIFY_CELL_ID)
        
        self.addSubview(self.allClassifyTableView)
    }
    
    func layoutAllClassifyViews() {
        self.allClassifyTableView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(10)
        }
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension LRChatBootExploreAllClassifyView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ALL_CLASSIFY_CELL_ID, for: indexPath) as? LRChatBootExploreAllClassifyCell else {
            return UITableViewCell()
        }
        cell.topicDelegate = self.topicDelegate
        return cell
    }
}
