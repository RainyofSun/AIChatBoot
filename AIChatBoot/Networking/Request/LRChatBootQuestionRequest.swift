//
//  LRChatBootQuestionRequest.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/14.
//

import UIKit

protocol ChatBootAIChunkedReplyProtocol: AnyObject {
    /// 准备开始传递AI回复
    func AI_preparedToReceiveAIReply()
    /// AI 分段回复
    func AI_chunkedReply(reply: String)
    /// AI 分段回复结束
    func AI_chunkedReplyEnd(error: Error?)
}

@available(iOS 15.0, *)
class LRChatBootQuestionRequest: NSObject {
    
    private weak var _url_session: URLSession?
    private var _request_task: Task<(), Never>?
    
    weak open var replyDelegate: ChatBootAIChunkedReplyProtocol?
    
    init(replyDelegate: ChatBootAIChunkedReplyProtocol? = nil) {
        self.replyDelegate = replyDelegate
    }
    
    deinit {
        deallocPrint()
    }

    // MARK: Public Methods
    /// 分段请求AI回复
    public func receiveAIReplyByChunked(problems: [[String: Any]] ) {
        self._request_task = Task.detached {
            do {
                if let stream: AsyncThrowingStream = await self.sendRequest(problems: ["messages": problems]) {
                    // 先清空上次回答
                    await MainActor.run {
                        self.replyDelegate?.AI_preparedToReceiveAIReply()
                    }
                    
                    // 拼接数据流
                    for try await text in stream {
                        await MainActor.run {
                            if text == "stop" {
                                self.replyDelegate?.AI_chunkedReplyEnd(error: nil)
                            } else {
                                self.replyDelegate?.AI_chunkedReply(reply: text)
                            }
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.replyDelegate?.AI_chunkedReplyEnd(error: error)
                }
            }
        }
    }
    
    /// 主动停止或者释放AI请求
    public func stopAIReplyRequest() {
        self._url_session?.invalidateAndCancel()
        self._url_session = nil
        self._request_task?.cancel()
        self._request_task = nil
    }
}

// MARK: Private Methods
@available(iOS 15.0, *)
private extension LRChatBootQuestionRequest {
    func sendRequest(problems: [String: Any]) async -> AsyncThrowingStream<String, Swift.Error>? {
        var _jsonData: Data?
        do {
            _jsonData = try JSONSerialization.data(withJSONObject: problems)
        } catch {
            Log.error("字典转化json 失败---------- \(error.localizedDescription)")
        }

        guard let _j_d = _jsonData else {
            return nil
        }

        var request: URLRequest = URLRequest(url: URL.init(string: (HOST_URL + "/fbuf/v1/openai/stream/chat/completions"))!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(AuthManager.authorization, forHTTPHeaderField: "Authorization")
        request.httpBody = _j_d
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(600)
        configuration.timeoutIntervalForResource = TimeInterval(600)
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        
        let session = URLSession(configuration: configuration)
        self._url_session = session
        
        do {
            let (result, _) = try await session.bytes(for: request)
            return AsyncThrowingStream<String, Swift.Error> { continuation in
                _Concurrency.Task(priority: .userInitiated) {
                    do {
                        for try await line3:String in result.lines {
                            // 丢掉前6个字符 --- "data: "
                            guard line3.hasPrefix("data: "), let jsonData = line3.dropFirst(6).data(using: .utf8) else {
                                print("有一帧解析失败了")
                                continue
                            }
                            // 解析某一帧数据
                            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
                            let decryptdDict = jsonString?.aesDecrypt(key: NET_REQUEST_SECRET_KEY)?.convertToDictionary()
                            if let _message = decryptdDict?["data"] as? [String: Any], let _msgs = _message["choices"] as? [[String: Any]], let _first = _msgs.first {
                                if let _contentMsg = _first["message"] as? [String: Any], let _content = _contentMsg["content"] as? String {
                                    continuation.yield(_content)
                                }
                                
                                if let _finishReason = _first["finishReason"] as? String, _finishReason == "stop" {
                                    // 数据全部传输完毕
                                    continuation.yield(_finishReason)
                                    break
                                }
                            }
                        }
                        // 全部解析完成，结束
                        continuation.finish()
                    } catch {
                        // 发生错误，结束
                        continuation.finish(throwing: error)
                    }
                    // 流终止后的回调
                    continuation.onTermination = { @Sendable status in
                        print("Stream terminated with status: \(status)")
                    }
                }
            }
        } catch {
            
        }
        
        return nil
    }
}
