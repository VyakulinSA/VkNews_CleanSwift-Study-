//
//  FeedResponse.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 07.01.2021.
//

import Foundation
//ВАЖНО: Весь этот один файл служит для декодирования огромного JSON в формат нужный нам, указывая в структурах, только те поля которые нам нужны, при декодировании JSON в эти модели данных только эти поля попадут, а остальные не будут использоваться

//ВАЖНО: для всех структур важно соблюдать наименование переменных точно так же как они приходят в JSON строке, иначе декодирование (Decodable) не пройдет
//мы знаем наименование полей из описания получаемых API данных вконтакте (см. работу с API на странице ВК)

//в файле модели данных создаем структуру для декодирования json файла в нужную нам структуру
struct FeedResponseWrapped: Decodable {
    let response: FeedResponse
}

//ответ от API вконтакте возвращает нам информацию в огромном JSON формате (поля в JSON см в описание API вконтакте)
//мы декодируем огромный файл только в нужные нам поля структура ниже
struct FeedResponse: Decodable {
    //каждое из ниженаписанных полей, имеет в себе еще данные, поэтому согдаем как массив еще одних структур
    var items: [FeedItem]
    var profiles: [FeedProfile]
    var groups: [FeedGroup]
}

//создаем поля для записи данных которые нам нужны для парсинга JSON
struct FeedItem: Decodable {
    //sourceId - необходим для понимания, новость от пользователя или от группы (см. описание работы с API)
    //хранит в себе положительное или отрицательное число (положительное/отрицательное - пользователь/группа, число - идентификатор записи, для поиска сопутствующей информации)
    //числа соответствуют id группы или пользователя
    let sourceId: Int
    let postId: Int
    let text: String?
    let date: Double
    let comments: CountableItem?
    let likes: CountableItem? //данные поля, хранят внутри себя еще значение count, поэтому уходим ниже и создаем еще структуру
    let reposts: CountableItem?
    let views: CountableItem?
    let attachments: [Attachment]?
}

struct Attachment: Decodable {
    let photo: Photo?
}

struct Photo: Decodable {
    let sizes: [PhotoSize] //используется массив Size потому что ВК передает для каждый фотографии различные вариации ее размеров, чтобы нам постоянно не грузить больши фотографии если в этом нет необходимости
    
    var heiht: Int {
        return getPropperSize().height
    }
    var width: Int {
        getPropperSize().width
    }
    var srcBIG: String {
        return getPropperSize().url
    }
    
    private func getPropperSize() -> PhotoSize {
        if let sizeX = sizes.first(where: {$0.type == "x"}) {
            return sizeX
        } else if let fallBackSize = sizes.last {
            return fallBackSize
        }else {
            return PhotoSize(type: "wrong image", url: "wrong image", width: 0, height: 0)
        }
        
    }
}

struct PhotoSize: Decodable {
    let type: String
    let url: String
    let width: Int
    let height: Int
}

//создаем поля для записи данных которые нам нужны для парсинга JSON
struct CountableItem: Decodable{
    let count: Int
}

//создадим протокол для пользователя и группы с общими свойствами, чтобы мы могли обращаться по одному шаблону по одним и тем же параметрам
protocol ProfileRepresentable {
    var id: Int { get }
    var name: String { get }
    var photo: String { get }
}


//создаем поля для записи данных которые нам нужны для парсинга JSON
struct FeedProfile: Decodable, ProfileRepresentable {
    let id: Int
    let firstName: String
    let lastName: String
    let photo100: String
    
    var photo: String {return photo100}
    var name: String {return firstName + " " + lastName}
    
}
//создаем поля для записи данных которые нам нужны для парсинга JSON
struct FeedGroup: Decodable, ProfileRepresentable {
    let id: Int
    let name: String
    let photo100: String
    
    var photo: String {return photo100}
}
