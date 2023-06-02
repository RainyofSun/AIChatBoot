//
//  LRChatBootSettingViewController.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/31.
//

import UIKit

class LRChatBootSettingViewController: UIViewController {

    private lazy var settingTableView: UITableView = {
        let view = UITableView(frame: CGRectZero, style: UITableView.Style.plain)
        view.showsVerticalScrollIndicator = false
        view.separatorStyle = .none
        view.backgroundColor = .clear
        return view
    }()
    
    private let SUBSCRIBE_CELL_ID: String = "com.AI.subscribe.cell"
    private let SETTING_CELL_ID: String = "com.AI.setting.cell"

    private var _setting_source: [[String: Any]] = [
        ["title":"", "image": "", "showArrow": false],
        ["title":LRLocalizableManager.localValue("settingRate"), "image": "setting_icon_rate", "showArrow": true],
        ["title":LRLocalizableManager.localValue("settingPrivacy"), "image": "setting_icon_pp", "showArrow": true],
        ["title":LRLocalizableManager.localValue("settingService"), "image": "setting_icon_ts", "showArrow": true],
        ["title":LRLocalizableManager.localValue("settingContact"), "image": "setting_icon_contect", "showArrow": true],
        ["title":LRLocalizableManager.localValue("settingAbout"), "image": "setting_icon_about", "showArrow": true],
        ["title":LRLocalizableManager.localValue("settingVersion"), "image": "setting_icon_version", "showArrow": false]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettingViews()
        layoutSettingViews()
    }

    deinit {
        deallocPrint()
    }
}

// MARK: Private Methods
private extension LRChatBootSettingViewController {
    func loadSettingViews() {
        self.view.backgroundColor = MainBGColor
        self.title = LRLocalizableManager.localValue("settingTitle")
        
        self.settingTableView.register(LRChatBootSettingSubscribeCell.self, forCellReuseIdentifier: SUBSCRIBE_CELL_ID)
        self.settingTableView.register(LRChatBootSettingCell.self, forCellReuseIdentifier: SETTING_CELL_ID)
        self.settingTableView.delegate = self
        self.settingTableView.dataSource = self
        
        self.view.addSubview(self.settingTableView)
    }
    
    func layoutSettingViews() {
        self.settingTableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(10)
            make.verticalEdges.equalToSuperview()
        }
    }
    
    func goWeb(url: String) {
        let WebVC: LRWebViewController = LRWebViewController()
        WebVC.webLinkUrl = url
        WebVC.webExtraInfo = ["showTitle": true, "hideCustomNav": true]
        self.navigationController?.pushViewController(WebVC, animated: true)
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension LRChatBootSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _setting_source.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _source = _setting_source[indexPath.row]
        guard let _t = _source["title"] as? String, let _i = _source["image"] as? String, let _showArrow = _source["showArrow"] as? Bool else {
            return UITableViewCell()
        }
        if _t.isEmpty && _i.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SUBSCRIBE_CELL_ID, for: indexPath) as? LRChatBootSettingSubscribeCell else {
                return UITableViewCell()
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SETTING_CELL_ID, for: indexPath) as? LRChatBootSettingCell else {
                return UITableViewCell()
            }
            
            cell.settingCellSource(title: _t, settingImage: _i, showArrow: _showArrow)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == .zero {
            self.goSubscribeControllerPage()
        }
        
        if indexPath.row == 1 {
            self.showAPPScore()
        }
        
        if indexPath.row == 2 {
            goWeb(url: APPPrivacy)
        }
        
        if indexPath.row == 3 {
            goWeb(url: APPService)
        }
    }
}
