//
//  LRChatBootAIRequest.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/7/11.
//

import UIKit
import Alamofire

class LRChatBootAIRequest: NSObject {
    
    private var streamRequest: DataStreamRequest?
    // 临时记录AI的回答
    private var _AI_reply_record: String = ""
    // 请求地址
    private lazy var requestUrl: String = HOST_URL + "/fbuf/v1/openai/stream/chat/completions"
    // 未读播报终止符集合
    private let _set_unread_broadcast_terminators: [String] = [".","...","?","!","\n"]
    // 未读播报
    private var _unread_broadcast: String = ""
    // 缓存未读播报
    private var _cache_unread_broadcasts: [String] = []
    
    private lazy var requestHeader: HTTPHeaders = {
        var httpHeader = HTTPHeaders()
        httpHeader.add(name: "Content-Type", value: "application/json")
        httpHeader.add(name: "Authorization", value: AuthManager.authorization ?? "")
        return httpHeader
    }()
    
    weak private var replyDelegate: ChatBootAIChunkedReplyProtocol?
    
    init(replyDelegate: ChatBootAIChunkedReplyProtocol? = nil) {
        self.replyDelegate = replyDelegate
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func requestQuestionToRoot(parameters: [[String: String]]) {
        // 清空临时标记
        _AI_reply_record = ""
        // 重置未读播报
        _unread_broadcast = ""
        _cache_unread_broadcasts.removeAll()
        
        self.streamRequest = AF.streamRequest(requestUrl, method: .post, parameters: ["messages": parameters], encoder: JSONParameterEncoder.default, headers: requestHeader, automaticallyCancelOnStreamError: false, interceptor: nil, requestModifier: nil).responseStreamString(on: .main, stream: { [weak self] stream in
            switch stream.event {
            case let .stream(result):
                switch result {
                case let .success(string):
                    if let _reply = self?._AI_reply_record, _reply.isEmpty {
                        // AI 准备回答
                        self?.replyDelegate?.AI_preparedToReceiveAIReply()
                    }
                    self?.chatBotDeserializeStreamString(string)
                case let .failure(error):
                    if let _reply = self?._AI_reply_record, _reply.isEmpty {
                        // AI 准备回答
                        self?.replyDelegate?.AI_preparedToReceiveAIReply()
                    }
                    self?._AI_reply_record = LRLocalizableManager.localValue("AITired")
                    Log.error("消息流请求失败 --------- \(error.localizedDescription)")
                    self?.replyDelegate?.AI_chunkedReplyEnd(error: error, broadcast: self?._cache_unread_broadcasts ?? [])
                }
                self?.replyDelegate?.AI_chunkedReply(reply: self?._AI_reply_record ?? "", broadcast: self?._cache_unread_broadcasts ?? [])
                self?._cache_unread_broadcasts.removeAll()
            case let .complete(completion):
                Log.debug("complete------\(String(describing: completion.response))")
                self?.replyDelegate?.AI_chunkedReplyEnd(error: nil, broadcast: self?._cache_unread_broadcasts ?? [])
                self?.freeRequest()
            }
        })
    }
    
    /// 释放请求
    public func freeRequest() {
        self.streamRequest?.cancel()
        self.streamRequest = nil
    }
}

// MARK: Private Methods
private extension LRChatBootAIRequest {
    func chatBotDeserializeStreamString(_ string: String) {
        
        let resultString = string.replacingOccurrences(of: "data: ", with: "")
        let desStrings = resultString.split("\r\n\r\n")

        for desString in desStrings {
            
            let decryptdDict = desString.aesDecrypt(key: NET_REQUEST_SECRET_KEY)?.convertToDictionary()
            var content = ""
            if let _message = decryptdDict?["data"] as? [String: Any], let _msgs = _message["choices"] as? [[String: Any]], let _first = _msgs.first {
                if let _contentMsg = _first["message"] as? [String: Any], let _content = _contentMsg["content"] as? String {
                    content = _content
                    _unread_broadcast += _content
                    for item in _set_unread_broadcast_terminators {
                        if _unread_broadcast.hasSuffix(item) {
//                            Log.info("一句话结束 ----- \(_unread_broadcast)")
                            _cache_unread_broadcasts.append(_unread_broadcast)
                            // 重置播报
                            _unread_broadcast = ""
                            break
                        }
                    }
                }
                
                if let _finishReason = _first["finishReason"] as? String, _finishReason == "stop" {
                    // 数据全部传输完毕
                    content = _finishReason
                    break
                }
            }
            
            if content != "stop" {
                self._AI_reply_record += content
            }
        }
    }
}
