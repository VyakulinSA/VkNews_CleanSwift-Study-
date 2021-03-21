//
//  UserResponse.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 26.01.2021.
//

import Foundation

//Структуры для парсинга Json данных по информации о юзере

struct UserresponseWrapped: Decodable {
    let response: [UserResponse]
}

struct UserResponse: Decodable {
    let photo100: String?
}
