//
//  LRChatBootTopicCollectionDB.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/5.
//

import UIKit
import WCDBSwift

class LRChatBootTopicCollectionDB: NSObject {
    private let AIChatTopicCollectionTable: String = "AIChatTopicCollectionTable"
    private let databaseFile = HSFilePath.filePath("ChatDB/AIChatTopicCollection.db")
    
    public static let shared = LRChatBootTopicCollectionDB()
    
    override init() {
        super.init()
        createChatTopicTable()
    }
    
    // MARK: Public Methods
    // MARK: 增
    /// 插入一条话题记录
    public func insertChatTopic(chatTopic: LRChatBootTopicModel) {
        let dataBase = Database.init(at: databaseFile)
        do {
            try dataBase.insert(chatTopic, intoTable: AIChatTopicCollectionTable)
        } catch {
            Log.error("insert chat topic collection result error: \(error)")
        }
    }
    
    // MARK: 删
    /// 删除整张表
    public func deleteAIChatCollectionTable() {
        let db = Database(at: databaseFile)
        do {
            guard try db.isTableExists(AIChatTopicCollectionTable) else { return }
            // 删除table
            try db.delete(fromTable: AIChatTopicCollectionTable)
            
        } catch  {
            Log.error("delete chat topic collection table failed: \(error)")
        }
    }
    
    /// 删除某一条话题
    /// chatTopicDBID: 数据库主键ID
    public func deleteChatTopic(chatTopicDBID: String) {
        let db = Database(at: databaseFile)
        do {
            guard try db.isTableExists(AIChatTopicCollectionTable) else {
                return
            }
            try db.delete(fromTable: AIChatTopicCollectionTable, where: LRChatBootTopicModel.Properties.identifier == chatTopicDBID)
        } catch  {
            Log.error("delete chat topic collection failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: 查
    /// 获取表内容
    public func findChatTopicRecords() -> [LRChatBootTopicModel]? {
        let db = Database(at: databaseFile)
        do {
            let allObjs: [LRChatBootTopicModel] = try db.getObjects(fromTable: AIChatTopicCollectionTable, orderBy: [LRChatBootTopicModel.Properties.identifier.order(Order.ascending)])
            return allObjs
        } catch  {
            Log.error("get all topis error: \(error.localizedDescription)")
        }
        return nil
    }
}

// MARK: Private Methods
private extension LRChatBootTopicCollectionDB {
    /// 创建表
    func createChatTopicTable() {
        let db = Database(at: databaseFile)
        Log.debug("db.paths: \(db.path)")
        do {
            try db.create(table: AIChatTopicCollectionTable, of: LRChatBootTopicModel.self)
        } catch  {
            Log.error("create table failed:\(error)")
        }
    }
}
