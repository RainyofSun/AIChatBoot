//
//  Networking.swift
//  HSTranslation
//
//  Created by 李昆明 on 2022/8/1.
//

import Moya
import SwiftyJSON
import UIKit
import Alamofire

public struct BaseResponse: Codable {
    let msg: String
    let code: Int
    let data: JSON?
    let rows: JSON?
    let timestamp: Int
}
public struct Language: Codable {
    var language: String
    let name: String
}
enum NetworkingError: Error {
    case noNetwork
    case badStatusCode(_ code: Int, _ msg: String)
}
/// 网络管理类
final class Networking {
    
    public typealias Completion = (_ result: Result<Moya.Response, MoyaError>) -> Void
    
    public typealias ComplateHandler = (Dictionary<String, Any>?, Error?) -> (Void)
    
    public typealias ArrayComplateHandler = ([Any]?, Error?) -> (Void)
    
    public typealias DownloadComplateHandler = (String?, Error?) -> (Void)
    
    public static let shared = Networking()
    
    // 默认Session
    static let defaultSession: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        configuration.allowsCellularAccess = true
        return Session(configuration: configuration, startRequestsImmediately: false)
    }()
    
    // 配置Moya插件
    public static var plugins: [PluginType] = [DecryptPlugin()]
    
    // MARK: - endpointClosure
    private let endpointClosure = { (target: Target) -> Endpoint in
        let url = target.baseURL.absoluteString + target.path
        var endpoint = Endpoint(
            url: url,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
        return endpoint
    }
    
    // MARK: - requestClosure
    private let requestClosure = { (endpoint: Endpoint, closure: MoyaProvider.RequestResultClosure) in
        do {
            var request = try endpoint.urlRequest()
            request.timeoutInterval = 30
            Log.debug("URL:\(String(describing: request.url?.path))>>>query:\(String(describing: request.url?.query))")
            closure(.success(request))
        } catch {
            closure(.failure(MoyaError.underlying(error, nil)))
        }
    }
    // MARK: 获取网络状态
    public func networkAvaible(_ completion: @escaping ((Bool) -> Void)) {
        let networkManager = NetworkReachabilityManager(host: "www.apple.com")
        if let networkReachabilityManager = networkManager {
            networkReachabilityManager.startListening { status in
                switch status {
                case .unknown, .notReachable:
                    completion(false)
                case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                    completion(true)
                }
            }
        }
    }
    // MARK: Request默认方法
    public func request(target: Target, completion: @escaping ComplateHandler, _ arryCompletion: ArrayComplateHandler? = nil) {
        let isReachable = LRNetStateManager.shared.netState != .NoNet
        Log.info("当前网络状态:\(isReachable)")
        guard isReachable else {
            completion(nil, NetworkingError.badStatusCode(1001, "Network is unreachable"))
            arryCompletion?(nil, NetworkingError.badStatusCode(1001, "Network is unreachable"))
            return
        }
        let provider = MoyaProvider(endpointClosure: self.endpointClosure, requestClosure: requestClosure, session: Networking.defaultSession, plugins: Networking.plugins)
        provider.request(target) { result in
            switch result {
            case  .success(let res):
                do {
                    let decoder = JSONDecoder()
                    let base = try decoder.decode(BaseResponse.self, from: res.data)
                    if base.code == 200 {
                        if let data = base.data {
                            completion(data.dictionaryObject, nil)
                        } else if let rows = base.rows {
                            if let arryCompletion = arryCompletion {
                                arryCompletion(rows.arrayObject, nil)
                            }
                        }
                    } else if base.code == 401 {
                        Log.warning("401")
                        AuthRefresh.refreshToken {
                            
                        } fail: {_ in
                            
                        }
                        completion(nil, NetworkingError.badStatusCode(base.code, base.msg))
                        arryCompletion?(nil, NetworkingError.badStatusCode(base.code, base.msg))
                    } else {
                        Log.error("code：\(base.code), msg: \(base.msg)")
                        if let jsonData = base.data {
                            let code = jsonData["code"]
                            let message = jsonData["message"]
                            if let code = code.rawValue as? Int, let message = message.rawValue as? String {
                                completion(nil, NetworkingError.badStatusCode(code, message))
                                arryCompletion?(nil, NetworkingError.badStatusCode(base.code, base.msg))
                            }
                        } else {
                            completion(nil, NetworkingError.badStatusCode(base.code, base.msg))
                            arryCompletion?(nil, NetworkingError.badStatusCode(base.code, base.msg))
                        }
                    }
                } catch  {
                    Log.error(error)
                    arryCompletion?(nil, error)
                    completion(nil, error)
                }
            case .failure(let error):
                Log.error(error)
                // Check if it's a timeout error
                if error.localizedDescription.contains("The request timed out.") {
                    completion(nil, NetworkingError.badStatusCode(2103, "net work time out"))
                    arryCompletion?(nil, NetworkingError.badStatusCode(2103, "net work time out"))
                } else {
                    // Handle other errors here
                    completion(nil, error)
                    arryCompletion?(nil, error)
                }
            }
        }
    }
}

