//
//  LRStartLoopVideoViewController.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/3/29.
//

import UIKit
import AVFoundation

class LRStartLoopVideoViewController: UIViewController {

    private lazy var bgLayer: CALayer = {
        let layer = CALayer()
        if let _path = Bundle.main.path(forResource: "newIaunchImage", ofType: "png") {
            layer.contents = UIImage.init(contentsOfFile: _path)?.cgImage
            layer.contentsGravity = .resizeAspectFill
        }
        return layer
    }()
    
    private lazy var videoPlayer: LRLoopVideoPlayer = LRLoopVideoPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgLayer.frame = self.view.bounds
        self.view.layer.addSublayer(bgLayer)
        playLocalVideo()
    }
    
    deinit {
        deallocPrint()
    }
    
    func playLocalVideo() {
        guard let _filePath = Bundle.main.path(forResource: "launch", ofType: "mp4"), let playerLayer: AVPlayerLayer = self.videoPlayer.playLocalVideosLoop(_filePath) else {
            return
        }
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
    }
}
