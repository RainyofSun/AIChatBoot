//
//  LRStartVideoViewController.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/9/26.
//

import UIKit
import AVKit

protocol HSStartVideoPlayProtocol: AnyObject {
    /// 开始播放
    func hs_startVideoBeginPlay()
    /// 播放完毕
    func hs_startVideoPlayEnd()
}

extension HSStartVideoPlayProtocol {
    /// 开始播放
    func hs_startVideoBeginPlay() {
        Log.debug("启动视频开始播放 --- 默认实现")
    }
}

class LRStartVideoViewController: LRChatBootBaseViewController {

    // 外部回调
    weak open var playDelegate: HSStartVideoPlayProtocol?
    // 播放器
    private lazy var videoPlayer: LRVideoPlayer = LRVideoPlayer()
    private var playerView: LRVideoPlayView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _path = Bundle.main.path(forResource: "newIaunchImage", ofType: "png") {
            self.view.layer.contents = UIImage.init(contentsOfFile: _path)?.cgImage
            self.view.layer.contentsGravity = .resizeAspectFill
        }
        self.view.backgroundColor = UIColor.init(hexString: "#262949")
        play()
    }

    override func didBecomeActive(notification: Notification) {
        super.didBecomeActive(notification: notification)
        self.videoPlayer.resume()
    }
    
    override func willEnterBackground(notification: Notification) {
        super.willEnterBackground(notification: notification)
        self.videoPlayer.pause()
    }
    
    deinit {
        self.videoPlayer.pause()
        self.playerView?.removeFromSuperview()
        self.playerView = nil
    }
    
    /// 播放
    func play() {
        guard let _path = LRHostAppBundleResource.appStartVideoPath(resourceName: "Launcher") else {
            return
        }
        let url = URL(fileURLWithPath: _path)
        videoPlayer.playDelegate = self
        videoPlayer.startPlayingAutomatically = true
        self.playerView = self.videoPlayer.playWithURL(videoUrl: url)
        self.view.addSubview(self.playerView!)
        playerView?.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
}

// MARK: VideoPlayProtocol
extension LRStartVideoViewController: VideoPlayProtocol {
    func videoReadyToPlay() {
        self.playDelegate?.hs_startVideoBeginPlay()
    }
    
    func videoPlayEnd() {
        self.playDelegate?.hs_startVideoPlayEnd()
    }
    
    func updateVideoPlayProgress(progress: Float) {
        
    }
    
    func updateVideoPlayProgressComplete() {

    }
}
