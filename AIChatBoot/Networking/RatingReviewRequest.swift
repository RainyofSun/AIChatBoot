//
//  RatingReviewRequest.swift
//  HSTranslation
//
//  Created by 李昆明 on 2022/9/20.
//

import Moya
import Foundation

public enum RatingReviewRequestPath: String {
    case feedbackList = "/v1/app/feedback/type/list"
    case commitFeedback = "/v1/app/feedback/add"
}

// 评分和反馈相关接口
public class RatingReviewTarget: Target {
    
    /// 反馈类型列表 Query
    func feedbackList(completeArray: @escaping Target.ComplateArrayHandler) {
        requestWithTarget(method: .Query, path: RatingReviewRequestPath.feedbackList.rawValue, params: nil, urlParams: nil, onComplete: nil, onCompleteArray: completeArray)
    }
    
    /*
     添加反馈意见 POST
     content: 内容限制300
     feedbackId 意见反馈ID(default = 0,'=0:新增'，>0:修改)
     star 反馈评分(0-5)
     type 反馈类型(作为反馈分类, default = 0, 先查看反馈类型)
     useId 反馈用户(无用户: default = 0)
     */
    func addFeedBack(content: String, star: Float = .zero, type: Int, pics: [String]? = nil, feedbackId: Int = .zero, mail: String? = nil, complete: @escaping ComplateHandler) {
        let query: [String: Any] = ["content": content, "feedbackId": feedbackId, "star": star, "type": type, "userId": "", "pics": pics ?? [], "mail": mail ?? ""]
        requestWithTarget(method: RequestType.POST, path: RatingReviewRequestPath.commitFeedback.rawValue, params: query, urlParams: nil, onComplete: complete)
    }

}

