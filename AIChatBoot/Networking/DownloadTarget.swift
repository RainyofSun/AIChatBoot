//
//  DownloadTarget.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/3/15.
//

import UIKit
import Moya

var downloadLocalPath: String?
var downloadBodyParams: [String: Any] = [:]
var downloadUrlParameters: [String: Any] = [:]
var downloadRequestType: RequestType?

public class DownloadTarget {
    
    public typealias DownloadComplateHandler = (String?, Error?) -> (Void)

    public func downWithTarget(videoName: String,method: RequestType, path: String, params: [String: Any]?, urlParams: [String: Any]?, onComplete: @escaping DownloadComplateHandler )  {
        downloadLocalPath = path + "/" + videoName
        downloadBodyParams = params ?? [:]
        downloadUrlParameters = urlParams ?? [:]
        downloadRequestType = method
        Networking.shared.downloadRequest(target: DownloadTarget()) { fileName, error in
            onComplete(fileName, error)
        }
    }
    private let downloadDestination: DownloadDestination = { temporaryURL, response in
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var fileURL: URL = documentsURL.appendingPathComponent("default.mp4")
        if let suggestedFilename = response.suggestedFilename {
            fileURL = documentsURL.appendingPathComponent(suggestedFilename)
            Log.debug(fileURL)
        }
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
}

extension DownloadTarget: TargetType {
    
    public var baseURL: URL { return URL(string: "https://cdn.conhor.pro")! }
    
    public var path: String {
        return downloadLocalPath ?? ""
    }
    
    public var method: Moya.Method {
        switch downloadRequestType {
        case .POST: return .post
        case .GET: return .get
        case .Query: return .get
        case .QueryDownLoad: return .get
        case .POSTDownLoad: return .post
        case .none: return .get
        }
    }
    
    public var task: Task {
        switch downloadRequestType {
        case .QueryDownLoad:
            return .downloadParameters(parameters: downloadUrlParameters, encoding: URLEncoding.queryString, destination: downloadDestination)
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        return ["Authorization": AuthManager.authorization ?? ""]
    }
    
}
