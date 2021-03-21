//
//  API.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 07.01.2021.
//

import Foundation

struct API {
    static let scheme = "https"
    static let host = "api.vk.com"
    static let version = "5.126"
    
    static let newsFeed = "/method/newsfeed.get"
    static let user = "/method/users.get"
}
