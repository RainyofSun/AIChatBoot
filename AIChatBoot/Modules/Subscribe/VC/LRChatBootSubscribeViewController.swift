//
//  LRChatBootSubscribeViewController.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/26.
//

import UIKit

class LRChatBootSubscribeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSubscribeViews()
        layoutSubscribeViews()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.navigationController?.dismiss(animated: true)
    }
    
    deinit {
        deallocPrint()
    }
}

// MARK: Private Methods
private extension LRChatBootSubscribeViewController {
    func loadSubscribeViews() {
        self.view.backgroundColor = MainBGColor
    }
    
    func layoutSubscribeViews() {
        
    }
}
