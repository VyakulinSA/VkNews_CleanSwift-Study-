//
//  NewsfeedInteractor.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 08.01.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol NewsfeedBusinessLogic {
    func makeRequest(request: NewsfeedModels.Model.Request.RequestType)
}

class NewsfeedInteractor: NewsfeedBusinessLogic {
    
    var presenter: NewsfeedPresentationLogic? //экземпляр класса для передачи данных дальше на presenter
    var service: NewsfeedService? //экземпляр класса, который находится в Worker - необходим для того, чтобы вызывать вспомогательные методы из отдельного файла
    
    private var revealedPostIds = [Int]() //создаем массив для хранения открытых постов
    private var feedResponse: FeedResponse?
    
    //создаем свойсвто для получеия и парсинга API данных
    private var fetcher: DataFetcher = NetworkDataFetcher(networking: NetworkService())
    
    
    //получает запрос от ViewController - и в зависимости от типа запроса (см switch request) выполняет логику
    func makeRequest(request: NewsfeedModels.Model.Request.RequestType) {
        if service == nil {
            service = NewsfeedService()
        }
        switch request {
        //если срабатывает указанный метод, он должен что то выполнить, и отправить ответ в Presenter, чтобы тот сформировал ViewModel и отдал ViewController
        case .getNewsfeed:
            //получаем красивый декодированный в нашу модель json ответ
            fetcher.getFeed { [weak self] (feedResponse) in
                self?.feedResponse = feedResponse
                //чтобы тот сформировал ViewModel и отдал ViewController выбираем нужный нам вариант ответа(который заранее вносим в NewsfeedModel)
                self?.presenFeed()//после срабатывания метода мы попадаем в файл Presenter
            }
        case .revealPostIds(postId: let postId):
            revealedPostIds.append(postId)
            presenFeed()
        case .getUser:
            fetcher.getUser { (userResponse) in
                self.presenter?.presentData(response: .presentUserInfo(user: userResponse))
                
            }
        }
    }
    
    private func presenFeed() {
        guard let feedResponse = self.feedResponse else {return}
        presenter?.presentData(response: NewsfeedModels.Model.Response.ResponseType.presentNewsfeed(feed: feedResponse, revealedPostIds: revealedPostIds))
    }
}

