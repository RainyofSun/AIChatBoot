//
//  AuthManager.swift
//  HSTranslation
//
//  Created by 李昆明 on 2022/8/1.
//

import Foundation
import Moya
import KeychainSwift

public final class AuthManager {
    private static let keychainAuthKey = "HSAuthrization"
    private lazy var keychain: KeychainSwift = {
        let keychain = KeychainSwift(keyPrefix: "AuthToken")
        return keychain
    }()
    private static let decoder = JSONDecoder()
    private static let encoder = JSONEncoder()
    
    public static let shared = AuthManager()
    required init() {}
    
    public static var authInfo: Auth? {
        guard let data = self.shared.keychain.getData(keychainAuthKey) else { return nil }
        return try? decoder.decode(Auth.self, from: data)
    }
    public static var authorization: String? {
        guard let authInfo = self.authInfo,
              let token = authInfo.access_token else { return "" }
        return "Bearer" + " " + token
    }
    
    public static var hasAuth: Bool {
        if let token = self.authInfo?.access_token, !token.isEmpty {
            return true
        }
        return false
    }
    
    public static var hasRetryed: Bool {
        set {}
        get { false }
    }
    
    public static func setAuth(with data: Data?) {
        guard let _d = data else {
            return
        }
        self.shared.keychain.set(_d, forKey: keychainAuthKey)
    }
    
    public static func setAuth(with auth: Auth?) {
        if let data = try? encoder.encode(auth) {
            setAuth(with: data)
        }
    }
    
    @discardableResult
    public static func cancleAuth() -> Bool {
        return self.shared.keychain.delete(keychainAuthKey)
    }
}

class AuthRefresh {
    public typealias TokenSuccessHandler = (() -> Void)
    public typealias TokenFailHandler = ((Error?) -> Void)
    public static func refreshToken(success:@escaping TokenSuccessHandler, fail:@escaping TokenFailHandler) {
        let params = ["apiKey": "com.smartclean.storagecleaner", "scope": "ios", "secretKey": NET_REQUEST_SECRET_KEY]
        CleanTarget().requestAuth(params: params) { res, err in
            if let dict = res,
               let data = dict.data {
                AuthManager.setAuth(with: data)
                success()
            } else {
                fail(err)
            }
        }
    }
}

extension Dictionary {
    public var data: Data? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
}

/// 授权信息
public struct Auth: Codable {
    public var access_token: String?
    public var token_type: String?
    public var expires_in: Double?
    public var scope: String?
    public var license: String?
}
