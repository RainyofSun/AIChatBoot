//
//  AIRequest.swift
//  HSTranslation
//
//  Created by 李昆明 on 2022/8/1.
//

import Moya
import Foundation

public enum AIChatRequestPath: String {
    case auth = "/v2/oauth/token/credentials"
    case AIChat = "/v1/openai/chat/completions"
    case AIQuestions = "/v1/openai/chat/completions/issue"
    case AIQuestionCategory = "/v1/openai/chat/completions/issue/category"
    case AIOperationStatistics = "/v1/openai/chat/completions/issue/"
}

// 相关接口聚合
class AIChatTarget: Target {
    /// Auth接口
    public func requestAuth(params: [String: Any]?, complete: @escaping CompleteHandler) {
        requestWithTarget(method: .POST, path: AIChatRequestPath.auth.rawValue, params: params, urlParams: nil, onComplete: complete)
    }

    /// 请求问题分类
    
}

class AIChatQuestionTarget: LRChatBootChatTarget {
    /// AI聊天消息
    public func AIChatRequest(params: [String: Any], complete: @escaping CompleteHandler) {
        
    }
}

/*
 @available(iOS 15.0, *)
 extension GPTAPI {
 static func ask(_ problem: Dictionary<String,Any>) async throws -> AsyncThrowingStream<String, Swift.Error> {
 let request = try createRequest(problem)
 let configuration = URLSessionConfiguration.default
 configuration.timeoutIntervalForRequest = TimeInterval(600)
 configuration.timeoutIntervalForResource = TimeInterval(600)
 configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
 configuration.urlCache = nil
 //        configuration.httpShouldUsePipelining = true
 let session = URLSession(configuration: configuration)
 
 let (result, rsp) = try await session.bytes(for: request)
 
 try checkResponse(rsp)
 
 return AsyncThrowingStream<String, Swift.Error> { continuation in
 Task(priority: .userInitiated) {
 do {
 for try await line3:String in result.lines {
 
 // 解析某一帧数据
 
 guard let jsonData = line3.data(using: String.Encoding.utf8, allowLossyConversion: false) else { return }
 let jsonNew = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
 
 let json = JSON(jsonNew as Any)
 print("json", json)
 //                        print(json)
 if let content = json["choices"][0]["delta"]["content"].string {
 continuation.yield(content)
 }
 
 
 if let finishReason = json["choices"][0]["finish_reason"].string, finishReason == "stop" {
 // 全部拿完了
 break
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
 }
 }
 */
