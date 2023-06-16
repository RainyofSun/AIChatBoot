//
//  Target.swift
//  HSTranslation
//
//  Created by 李昆明 on 2022/8/1.
//

import Foundation
import Moya

class Target {
    public func requestWithTarget(method: RequestType, path: String, params: [String: Any]?, urlParams: [String: Any]?, onComplete: CompleteHandler? = nil, onCompleteArray: CompleteArrayHandler? = nil)  {
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

extension Target: TargetType {
    
    public var baseURL: URL { return URL(string: HOST_URL)! }
    
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
        case .GET:
            return .requestPlain
        case .Query:
            return .requestParameters(parameters: urlParameters, encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        return ["Authorization": AuthManager.authorization ?? ""]
    }
    
}


