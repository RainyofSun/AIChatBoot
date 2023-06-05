//
//  AuthPlugin.swift
//  HSTranslation
//
//  Created by 李昆明 on 2022/8/1.
//

import Foundation
import Moya

/// 权限验证网络插件
/// 1. OSS token 处理
/// 2. 全局处理 401
class AuthPlugin: PluginType {

    public init() {}
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        #if DEBUG
        log(request)
        #endif
        return request
    }
    
    public func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        return result
    }
    private func log(_ request: URLRequest) {
        var bodyInfo = ""
        if let bodyData = request.httpBody {
            let string = String(data: bodyData, encoding: .utf8) ?? ""
            bodyInfo = "\n body:" + string
        }
        
        if let method = request.httpMethod, let headers = request.allHTTPHeaderFields {
            Log.info("{ Request \n  URL: \(request.url!)"
                     + "\n method:\(method)"
                     + "\n Headers: \(headers)"
                     + bodyInfo
                     + "\n }"
            )
        } else {
            Log.info("\(request.url!)"+"\(String(describing: request.httpMethod))")
        }
    }
}
