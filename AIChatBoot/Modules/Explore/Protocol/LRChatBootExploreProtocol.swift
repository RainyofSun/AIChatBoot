//
//  LRChatBootExploreProtocol.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/29.
//

import UIKit

protocol ChatBootExploreSliderProtocol: AnyObject {
    /// 点击话题的标签分类
    func AI_selectedTopicClassification(classificationID: String?, classifyIndex: Int)
}

// MARK: 下拉刷新代理
protocol ChatBootExploreRefreshProtocol: AnyObject {
    /// 下拉刷新当前分类数据
    func AI_refreshCategoryDataSource(refreshView: ChatBootExploreDataSourceProtocol?)
    /// 加载更多数据
    func AI_loadMoreDataSource(refreshView: ChatBootExploreDataSourceProtocol?, currentPage: Int?)
}

extension ChatBootExploreRefreshProtocol {
    /// 加载更多数据
    func AI_loadMoreDataSource(protocol: ChatBootExploreDataSourceProtocol?, currentPage: Int?) {
        
    }
}

// MARK: 更新接口
protocol ChatBootExploreDataSourceProtocol: AnyObject {
    /// 单独分类下更新数据
    func AI_refreshQuestionGroupsUnderCategory(questions: [LRChatBootTopicModel])
    /// 所有分类下更新数据
    func AI_refreshQuestionGroupsUnderAllCategory(questions: [[LRChatBootTopicModel]])
    /// 单独分类下加载更多数据
    func AI_loadMoreQuestionGroupsUnderCategory(questions: [LRChatBootTopicModel])
    /// 所有分类下加载更多数据
    func AI_loadMoreQuestionGroupsUnderAllCategory(questions: [[LRChatBootTopicModel]])
    /// 单独分类下数据已经全部加载完毕
    func AI_noMoreQuestionGroupsUnderCategory(questions: [LRChatBootTopicModel])
    /// 所有分类下数据已经全部加载完毕
    func AI_noMoreQuestionGroupsUnderAllCategory(questions: [[LRChatBootTopicModel]])
    /// 数据加载失败
    func AI_questionGroupsDataLoadFailed()
}

extension ChatBootExploreDataSourceProtocol {
    /// 单独分类下更新数据
    func AI_refreshQuestionGroupsUnderCategory(questions: [LRChatBootTopicModel]) {
        
    }
    
    /// 所有分类下更新数据
    func AI_refreshQuestionGroupsUnderAllCategory(questions: [[LRChatBootTopicModel]]) {
        
    }
    
    /// 单独分类下加载更多数据
    func AI_loadMoreQuestionGroupsUnderCategory(questions: [LRChatBootTopicModel]) {
        
    }
    
    /// 所有分类下加载更多数据
    func AI_loadMoreQuestionGroupsUnderAllCategory(questions: [[LRChatBootTopicModel]]) {
        
    }
    
    /// 单独分类下数据已经全部加载完毕
    func AI_noMoreQuestionGroupsUnderCategory(questions: [LRChatBootTopicModel]) {
        
    }
    
    /// 所有分类下数据已经全部加载完毕
    func AI_noMoreQuestionGroupsUnderAllCategory(questions: [[LRChatBootTopicModel]]) {
        
    }
    
    /// 数据加载失败
    func AI_questionGroupsDataLoadFailed() {
        
    }
}
