//
//  LRChatBootChatTarget.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/3.
//

import UIKit
import Moya

class LRChatBootChatTarget: NSObject {
    public typealias ComplateHandler = (Dictionary<String, Any>?, Error?) -> (Void)
    public typealias ComplateArrayHandler = ([Any]?, Error?) -> (Void)

    public func requestWithTarget(method: RequestType, path: String, params: [String: Any]?, urlParams: [String: Any]?, onComplete: ComplateHandler? = nil, onCompleteArray: ComplateArrayHandler? = nil)  {
        localPath = path
        bodyParams = params ?? [:]
        urlParameters = urlParams ?? [:]
        requestType = method
        Networking.shared.request(target: Target()) { dict, error in
            if let _complete = onComplete {
                _complete(dict, error)
            }
        } _: { array, error in
            if let onCompleteArray = onCompleteArray {
                onCompleteArray(array, error)
            }
        }
    }
}

extension LRChatBootChatTarget: TargetType {
    
    public var baseURL: URL { return URL(string: "https://cdn.conhor.pro")! }
    
    public var path: String {
        return localPath ?? ""
    }
    
    public var method: Moya.Method {
        switch requestType {
        case .POST: return .post
        case .GET: return .get
        case .Query: return .get
        case .QueryDownLoad: return .get
        case .POSTDownLoad: return .post
        case .none: return .get
        }
    }
    
    public var task: Task {
        switch requestType {
        case .POST:
            return .requestCompositeParameters(bodyParameters: bodyParams, bodyEncoding: JSONEncoding.default, urlParameters: urlParameters)
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        return ["Authorization": AuthManager.authorization ?? "", "Transfer-Encoding": "chunked"]
    }
    
}
