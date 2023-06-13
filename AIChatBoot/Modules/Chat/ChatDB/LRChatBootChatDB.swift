//
//  LRChatBootChatDB.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/2.
//

import UIKit
import WCDBSwift

class LRChatBootChatDB: NSObject {
    private let AIChatTable: String = "AIChatTable"
    private let databaseFile = HSFilePath.filePath("ChatDB/AIChat.db")
    
    public static let shared = LRChatBootChatDB()
    
    /// 创建表
    /// topicId: 话题的唯一标识ID
    func createChatRecordTable(topicId: String) {
        let db = Database(at: databaseFile)
        Log.debug("db.paths: \(db.path)")
        do {
            try db.create(table: (AIChatTable + topicId), of: LRChatBootChatModel.self)
        } catch  {
            Log.error("create table failed:\(error)")
        }
    }
    
    // MARK: Public Methods
    // MARK: 增
    /// 插入一条聊天记录
    /// chat: 要插入的数据模型
    /// topicId: 话题的唯一标识ID
    public func insertChatRecord(chat: LRChatBootChatModel, topicID: String) {
        let dataBase = Database.init(at: databaseFile)
        do {
            try dataBase.insert(chat, intoTable: (AIChatTable + topicID))
        } catch {
            Log.error("insert chat result error: \(error)")
        }
    }
    
    /// 替换一条聊天记录
    /// chat: 要插入的数据模型
    /// topicId: 话题的唯一标识ID
    public func replaceChatRecord(chat: LRChatBootChatModel, topicID: String) {
        let dataBase = Database.init(at: databaseFile)
        do {
            try dataBase.insertOrReplace(chat, intoTable: (AIChatTable + topicID))
        } catch {
            Log.error("replace chat result error: \(error)")
        }
    }
    
    /// 批量插入聊天记录
    /// chats: 要插入的数据模型
    /// topicId: 话题的唯一标识ID
    public func batchInsertChatRecords(chats: [LRChatBootChatModel], topicID: String) {
        let dataBase = Database.init(at: databaseFile)
        let dbName = AIChatTable + topicID
        do {
            try dataBase.run(transaction: { _ in
                for chat in chats {
                    try dataBase.insert(chat, intoTable: dbName)
                }
            })
        } catch  {
            Log.error("insert chat records failed: \(error)")
        }
    }
    
    // MARK: 删
    /// 删除整张表
    /// topicId: 话题的唯一标识ID
    public func deleteAIChatTable(topicID: String) {
        let db = Database(at: databaseFile)
        let dbName = AIChatTable + topicID
        do {
            guard try db.isTableExists(dbName) else { return }
            // 删除table
            try db.delete(fromTable: dbName)
            
        } catch  {
            Log.error("delete chat table failed: \(error)")
        }
    }
    
    // MARK: 改
    /// 更新表中的消息
    /// topicId: 话题的唯一标识ID
    /// updateModel: 聊天序列号
    public func updateChatModel(topicId: String, updateChatModel updateModel: LRChatBootChatModel) {
        let db = Database(at: databaseFile)
        let dbName = AIChatTable + topicId
        do {
            try db.update(table: dbName, on: [LRChatBootChatModel.Properties.isWaittingForAIReply,
                                              LRChatBootChatModel.Properties.chatContent,
                                              LRChatBootChatModel.Properties.animationComplete], with: updateModel, where: LRChatBootChatModel.Properties.identifier == updateModel.identifier ?? .zero)
        } catch  {
            Log.error("update chat model error = \(error.localizedDescription)")
        }
    }
    
    // MARK: 查
    /// 获取表内容
    /// topicId: 话题的唯一标识ID
    public func findChatRecordsBasedOnTopicID(topicID: String) -> [LRChatBootChatModel]? {
        let db = Database(at: databaseFile)
        let dbName = AIChatTable + topicID
        do {
            let allObjs: [LRChatBootChatModel] = try db.getObjects(fromTable: dbName, orderBy: [LRChatBootChatModel.Properties.identifier.order(Order.ascending)])
            return allObjs
        } catch  {
            Log.error("get all chats error: \(error.localizedDescription)")
        }
        return nil
    }
    
    /// 获取聊天内容
    /// topicId: 话题的唯一标识ID
    /// serialNumber: 聊天序列号
    public func findChatMessageBasedOnTopicID(topicID: String, chatSerialNumber serialNumber: Int) -> LRChatBootChatModel? {
        let db = Database(at: databaseFile)
        let dbName = AIChatTable + topicID
        do {
            let obj: LRChatBootChatModel? = try db.getObject(fromTable: dbName, where: LRChatBootChatModel.Properties.chatSerialNumber == serialNumber, orderBy: [LRChatBootChatModel.Properties.identifier.order(Order.ascending)])
            return obj
        } catch  {
            Log.error("get chat error: \(error.localizedDescription)")
        }
        return nil
    }
}
