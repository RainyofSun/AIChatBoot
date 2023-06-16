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
    public func requestAIQuestionCategory(complete: @escaping CompleteArrayHandler) {
        requestWithTarget(method: .GET, path: AIChatRequestPath.AIQuestionCategory.rawValue, params: nil, urlParams: ["pageNum": 1, "pageSize": 10], onCompleteArray: complete)
    }
    
    /// 请求问题列表
    public func requestAIQuestionList(params: [String: Any]?, complete: @escaping CompleteArrayHandler) {
        requestWithTarget(method: .GET, path: AIChatRequestPath.AIQuestions.rawValue, params: nil, urlParams: params, onCompleteArray: complete)
    }
    
    /// AI聊天消息
    public func AIChatRequest(chatParams: [[String: Any]], complete: @escaping CompleteArrayHandler) {
        requestWithTarget(method: RequestType.POST, path: AIChatRequestPath.AIChat.rawValue, params: ["messages": chatParams], urlParams: nil) { (response: Dictionary<String, Any>?, error: Error?) in
            guard error == nil else {
                complete(nil, error)
                return
            }
            
            guard let _data = response?["choices"] as? [[String: Any]] else {
                complete(nil, error)
                return
            }
            
            complete(_data, error)
        }
    }
}
