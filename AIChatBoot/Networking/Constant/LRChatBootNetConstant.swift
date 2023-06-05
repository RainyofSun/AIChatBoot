//
//  LRChatBootNetConstant.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/3.
//

import UIKit

public enum RequestType {
    case GET, POST, Query, QueryDownLoad, POSTDownLoad
}

var localPath: String?
var bodyParams: [String: Any] = [:]
var urlParameters: [String: Any] = [:]
var requestType: RequestType?

public typealias CompleteHandler = (Dictionary<String, Any>?, Error?) -> (Void)
public typealias CompleteArrayHandler = ([Any]?, Error?) -> (Void)
