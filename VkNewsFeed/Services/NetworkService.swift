//
//  NetworkService.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 07.01.2021.
//

import Foundation

protocol Networking {
    func request(path: String, params: [String: String], completion: @escaping (Data?, Error?) -> Void)
}

//для работы с запросом нам необходим класс работы с сетью
class NetworkService: Networking {
    //хранимое свойство авторизации
    private let authService: AuthService
    
    //инициализатор сразу с инициализацией из синглтона
    init(authService: AuthService = SceneDelegate.shared().authService) {
        self.authService = authService
    }
    
    //метод запроса API
    func request(path: String, params: [String : String], completion: @escaping (Data?, Error?) -> Void) {
        //Пример URL - https://api.vk.com/method/users.get?user_ids=210700286&fields=bdate&access_token=533bacf01e11f55b536a565b57531ac114461ae8736d6506a3&v=5.126
        //scheme (протокол) - https
        //host - api.vk.com
        //path - /method/users.get
        //queryItems - user_ids=210700286&fields=bdate&access_token=533bacf01e11f55b536a565b57531ac114461ae8736d6506a3&v=5.126
        //проверим, что у нас есть токен пользователя
        guard let token = authService.token else {return}
        //создаем URL на основе компонентов
        //params - параметры для запроса newsfeed (см. документация запроса)
        var allParams = params
        allParams["access_token"] = token
        allParams["v"] = API.version
        let url = self.url(from: path, params: allParams)
        
        let request = URLRequest(url: url)
        let task = createDataTask(from: request, completion: completion)
        task.resume()
//        print(url)
    }
    
    //выделим в отдельный метод получение dataTask из сессии
    private func createDataTask(from request: URLRequest, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completion(data,error)
            }
        }
    }
    
    
    //кастомная функция для создания URL с разными параметрами и методами
    private func url(from path: String, params: [String: String]) -> URL {
        //для создания запроса, нам необходимы компоненты URL
        var components = URLComponents()
        
        components.scheme = API.scheme
        components.host = API.host
        components.path = path
        components.queryItems = params.map{ URLQueryItem(name: $0, value: $1)}
        
        return components.url!
    }
}
