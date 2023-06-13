//
//  LRChatBootChatTopicDB.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/3.
//

import UIKit
import WCDBSwift

class LRChatBootChatTopicDB: NSObject {
    private let AIChatTopicTable: String = "AIChatTopicTable"
    private let databaseFile = HSFilePath.filePath("ChatDB/AIChatTopic.db")
    
    public static let shared = LRChatBootChatTopicDB()
    
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
            try dataBase.insert(chatTopic, intoTable: AIChatTopicTable)
        } catch {
            Log.error("insert chat topic result error: \(error)")
        }
    }
    
    // MARK: 删
    /// 删除整张表
    public func deleteAIChatTable() {
        let db = Database(at: databaseFile)
        do {
            guard try db.isTableExists(AIChatTopicTable) else { return }
            // 删除table
            try db.delete(fromTable: AIChatTopicTable)
            
        } catch  {
            Log.error("delete chat topic table failed: \(error)")
        }
    }
    
    /// 删除某一条话题
    /// chatTopicDBID: 数据库主键ID
    public func deleteChatTopic(chatTopicDBID: Int) {
        let db = Database(at: databaseFile)
        do {
            guard try db.isTableExists(AIChatTopicTable) else {
                return
            }
            try db.delete(fromTable: AIChatTopicTable, where: LRChatBootTopicModel.Properties.identifier == chatTopicDBID)
        } catch  {
            Log.error("delete chat topic failed: \(error.localizedDescription)")
        }
    }
    
    /// 批量删除话题
    public func batchDeleteTopicRecords(chatTopidIDs: [String]) {
        let db = Database(at: databaseFile)
        do {
            try db.run(transaction: { _ in
                for topicId in chatTopidIDs {
                    try db.delete(fromTable: self.AIChatTopicTable, where: LRChatBootTopicModel.Properties.identifier == topicId)
                }
            })
        } catch  {
            Log.error("batch delete chat topic error: \(error.localizedDescription)")
        }
    }
    
    // MARK: 改
    /// 更新当前话题下消息数
    /// topicModel 话题Model
    public func updateTopicTotalNumberOfChatMessages(topicModel: LRChatBootTopicModel) {
        let db = Database(at: databaseFile)
        do {
            try db.update(table: AIChatTopicTable, on: [LRChatBootTopicModel.Properties.totalNumberOfChatMessages], with: topicModel, where: LRChatBootTopicModel.Properties.identifier == topicModel.identifier ?? .zero)
        } catch  {
            Log.error("update chat number failed: \(error)")
        }
    }
    
    // MARK: 查
    /// 获取表内容
    public func findChatTopicRecords() -> [LRChatBootTopicModel]? {
        let db = Database(at: databaseFile)
        do {
            let allObjs: [LRChatBootTopicModel] = try db.getObjects(fromTable: AIChatTopicTable, orderBy: [LRChatBootTopicModel.Properties.identifier.order(Order.descending)])
            return allObjs
        } catch  {
            Log.error("get all topis error: \(error.localizedDescription)")
        }
        return nil
    }
    
    /// 根据聊天记录ID查询话题模型
    public func findChatTopicAccordingTopicID(chatRecordID: String) -> LRChatBootTopicModel? {
        let db = Database(at: databaseFile)
        do {
            let topicModel: LRChatBootTopicModel? =  try db.getObject(fromTable: AIChatTopicTable, where: LRChatBootTopicModel.Properties.chatRecordID == chatRecordID, orderBy: [LRChatBootTopicModel.Properties.identifier.order(Order.descending)])
            return topicModel
        } catch  {
            Log.error("get chat topic model error: \(error.localizedDescription)")
        }
        return nil
    }
}

// MARK: Private Methods
private extension LRChatBootChatTopicDB {
    /// 创建表
    func createChatTopicTable() {
        let db = Database(at: databaseFile)
        Log.debug("db.paths: \(db.path)")
        do {
            try db.create(table: AIChatTopicTable, of: LRChatBootTopicModel.self)
        } catch  {
            Log.error("create table failed:\(error)")
        }
    }
}
