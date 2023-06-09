//
//  LRChatBootTopicCategoryModel.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/8.
//

import UIKit
import HandyJSON

struct LRChatBootTopicCategoryModel: HandyJSON {

    /// 分类ID
    var categoryId: String?
    /// 分类名
    var categoryName: String?
    /// 分类图片
    var categoryIconUrl: String? {
        didSet {
            if let _url = categoryIconUrl {
               categoryIconUrl = CDN_PREFFIX + _url
            }
        }
    }
    /// 分类颜色
    var categoryColor: String?
    /// 分类介绍
    var categoryIntroduction: String?
    
    /// 创建所有分类
    static func buildAllCategoryModel() -> Self {
        var model = LRChatBootTopicCategoryModel()
        model.categoryName = "All"
        model.categoryId = "0"
        return model
    }
}
