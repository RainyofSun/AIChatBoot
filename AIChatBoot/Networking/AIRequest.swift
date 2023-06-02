//
//  AIRequest.swift
//  HSTranslation
//
//  Created by 李昆明 on 2022/8/1.
//

import Moya
import Foundation

public enum CleanRequestPath: String {
    case auth = "/v2/oauth/token/credentials"
    case AIChat = "/v1/openai/chat/completions"
    case AIQuestions = "/v1/openai/chat/completions/issue"
    case AIQuestionCategory = "/v1/openai/chat/completions/issue/category"
    case AIOperationStatistics = "/v1/openai/chat/completions/issue/"
}
//LDv8rJW0$/BGCYHIBzl3J8/9DYlRzj.
// 相关接口聚合
public class CleanTarget: Target {
    /// Auth接口
    public func requestAuth(params: [String: Any]?, complete: @escaping ComplateHandler) {
        requestWithTarget(method: .POST, path: CleanRequestPath.auth.rawValue, params: params, urlParams: nil, onComplete: complete)
    }

}

public class CleanDownloadTarget: DownloadTarget {
    /// 下载充电动画
    public func downloadChargingAnimationVideoFile(fileAddress: String, videoName: String, onComplete: @escaping DownloadComplateHandler) {
        downWithTarget(videoName: videoName, method: RequestType.QueryDownLoad, path: fileAddress, params: nil, urlParams: nil, onComplete: onComplete)
    }
}
