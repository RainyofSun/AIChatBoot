//
//  LRChatBootSpeechSynthesizer.swift
//  ChatAIAPP
//
//  Created by JUDOT33 on 2023/5/29.
//

import UIKit
import Speech

protocol ChatBootSpeechProtocol: AnyObject {
    /// 语音播放开始
    func AI_speechStart()
    /// 语音播放进度
    func AI_speechProgress(progress: Float)
    /// 是否静音播放
    func AI_mutePlayback() -> Bool
}

extension ChatBootSpeechProtocol {
    /// 语音播放进度
    func AI_speechProgress(progress: Float) {
        
    }
}

class LRChatBootSpeechSynthesizer: NSObject {
    
    weak open var speechDelegate: ChatBootSpeechProtocol?
    
    private var speechUtterance: AVSpeechUtterance?
    private var synthesizer: AVSpeechSynthesizer? = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        do {
           try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: .duckOthers)
        } catch {
           print(error.localizedDescription)
        }
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func speechAIMessage(with message: String) {
        if let _speaking = synthesizer?.isSpeaking, _speaking {
            synthesizer?.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        speechUtterance = AVSpeechUtterance(string: message)
        speechUtterance?.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechUtterance?.rate = 0.5
        speechUtterance?.postUtteranceDelay = 0.1 //播放下一句前暂停 0.1S
        if let _mute = self.speechDelegate?.AI_mutePlayback() {
            speechUtterance?.volume = _mute ? .zero : AVAudioSession.sharedInstance().outputVolume
        }
        if synthesizer == nil{
            synthesizer = AVSpeechSynthesizer()
            synthesizer?.delegate = self
        }
        synthesizer?.speak(speechUtterance!)
    }

    public func pauseSpeaking()  {
        if synthesizer?.isSpeaking != nil {
            synthesizer?.pauseSpeaking(at: .word)
        }
    }
    
    public func speaking()  {
        if synthesizer?.isPaused != nil {
            synthesizer?.continueSpeaking()
        }
    }

    public func stopSpeaking() {
        if let _ = speechUtterance {
            synthesizer?.stopSpeaking(at: .immediate)
            speechUtterance = nil
            synthesizer = nil
        }
    }
    
    /// 释放资源
    public func free() {
        stopSpeaking()
        self.speechUtterance = nil
        synthesizer?.delegate = nil
        synthesizer = nil
    }
}

extension LRChatBootSpeechSynthesizer: AVSpeechSynthesizerDelegate {

    //开始播放
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {

    }
    
    //播放完成
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance){
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print(error.localizedDescription)
        }
        speechUtterance = nil
    }
}
