//
//  NetworkDataFetcher.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 07.01.2021.
//

import Foundation

//протокол для преображения json данных в формат который нам нужен
protocol DataFetcher {
    //метод для преображения данных в формат нашей модели FeedResponse
    func getFeed(response: @escaping (FeedResponse?) -> Void)
    
    //метод для преображения данных в формат нашей модели UserResponse
    func getUser(response: @escaping (UserResponse?) -> Void)
}

struct NetworkDataFetcher: DataFetcher {
    
    //свойство для экземпляра класса Networking
    let networking: Networking
    private let authService: AuthService 
    
    init(networking: Networking, authService: AuthService = SceneDelegate.shared().authService) {
        self.networking = networking
        self.authService = authService
    }
    
    func getUser(response: @escaping (UserResponse?) -> Void) {
        guard let userId = authService.userId else {return}
        //параметры для запроса
        let params = ["user_ids": userId, "fields": "photo_100"]
        networking.request(path: API.user, params: params) { (data, error) in
            if let error = error {
                print("Error received requesting data: \(error.localizedDescription)")
                response(nil)
            }
            let decoded = self.decodeJSON(type: UserresponseWrapped.self, from: data)
            response(decoded?.response.first)
            
        }
    }
    
    
    //метод для получения новостной ленты
    func getFeed(response: @escaping (FeedResponse?) -> Void) {
        //параметры для запроса
        let params = ["filters": "post, photo"]
        //отправляем запрос
        networking.request(path: API.newsFeed, params: params) { (data, error) in
            //получаем в замыкании data или error
            if let error = error {
                print("Error received requesting data: \(error.localizedDescription)")
                response(nil)
            }
            //декодируем из полученной data - JSSON в нашу модель
            let decoded = self.decodeJSON(type: FeedResponseWrapped.self, from: data)
            //возвращаем в замыкании декодированный в нашу модель данных ответ json
            response(decoded?.response)
        }
    }
    
    //функция для декодирования JSON в любой формат переданный в данную функцию
    //сделано на дженериках, чтобы быть универсальным и использовать 2 принцип SOLID
    //благодаря данной функции мы можем передавать любую модуль данных под нужный нам json и он будет его декодировать
    private func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let data = from, let response = try? decoder.decode(type.self, from: data) else {return nil}
        return response
    }
    
    
}
