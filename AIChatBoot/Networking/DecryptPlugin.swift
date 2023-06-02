//
//  Decrypt.swift
//  HSTranslation
//
//  Created by 李昆明 on 2022/8/1.
//

import Foundation
import Moya
/// 数据解密插件
/// 1.AES解密
/// 2.DES解密
class DecryptPlugin: PluginType {
    public init() {}
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
#if DEBUG
        log(request)
#else
        if Device().isUsedProxy() {
            print("isProxy")
            return URLRequest(url: URL(string: "nothing")!)
        }
#endif
        return request
    }
    
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        if case .success(let res) = result {
            let jsonString = String(data: res.data, encoding: .utf8) ?? ""
            let decryptdString = jsonString.aesDecrypt(key: NET_REQUEST_SECRET_KEY)
            guard let _data = decryptdString?.data(using: String.Encoding.utf8) else {
                return result
            }
            return .success(Response.init(statusCode: res.statusCode, data: _data))
        } else {
            Log.error("DecryptPlugin fail: 请求failure")
        }
        return result
    }
}
/// 网络请求参数日志
private func log(_ request: URLRequest) {
    var bodyInfo = ""
    if let bodyData = request.httpBody {
        let string = String(data: bodyData, encoding: .utf8) ?? ""
        bodyInfo = "\n body:" + string
    }
    
    if let method = request.httpMethod, let headers = request.allHTTPHeaderFields {
        Log.debug("{ Request \n  URL: \(request.url!)"
                 + "\n method:\(method)"
                 + "\n Headers: \(headers)"
                 + bodyInfo
                 + "\n }"
        )
    } else {
        Log.debug("\(request.url!)"+"\(String(describing: request.httpMethod))")
    }
}
