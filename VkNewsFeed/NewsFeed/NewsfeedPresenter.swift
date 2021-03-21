//
//  NewsfeedPresenter.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 08.01.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol NewsfeedPresentationLogic {
    func presentData(response: NewsfeedModels.Model.Response.ResponseType)
}

class NewsfeedPresenter: NewsfeedPresentationLogic {
    weak var viewController: NewsfeedDisplayLogic? //будущий экземпляр для передачи viewModel на ViewController
    //создаем объект с помощью которого мы будем считать размеры, его подписываем под протокол, чтобы могли использовать все внутренние функции
    var cellLayoutCalculator: FeedCellLayoutCalculatorProtocol = FeedCellLayoutCalculator()
    
    //создадим DateFormatter для преобразования даты в нужный нам формат
    let dateFormatter: DateFormatter = {
       let dt = DateFormatter()
        dt.locale = Locale(identifier: "ru_RU")
        dt.dateFormat = "d MMM 'в' HH:mm"
        return dt
    }()
    
    //    после перехода от Interactora запускается метод presenter
    func presentData(response: NewsfeedModels.Model.Response.ResponseType) {
        //        добавляем вариативность наших ответов
        switch response {
        //кейс с ассоциативным парметром, чтобы можно было передать в него инфрмацию из вне, при выборе кейса
        case .presentNewsfeed(feed: let feed, let revealedPostIds):
            //здесь подгатавливаем наши данные, чтобы дальше передать во viewController требуемую ViewModel
            //получаем данные items, profiles, groups из входящего массива данных feed и преобразуем во ViewModel
            let cells = feed.items.map{ (feedItem) in
                //для каждого item в массиве данных feed вызываем трансформацию в FeedViewModel.Cell, чтобы получить нужный нам для отображения массив (см. функцию ниже)
                cellViewModel(from: feedItem, feedProfiles: feed.profiles, feedGroups: feed.groups, revealedPostIds: revealedPostIds)
            }
            //инициализируем ViewModel массивом ячеек - тем самым получаем массив с ячейками, который далее отобразим на экране
            let feedViewModel = FeedViewModel.init(cells: cells)
            //передаем полученную модель данны на контроллер
            viewController?.displayData(viewModel: NewsfeedModels.Model.ViewModel.ViewModelData.displayNewsfeed(feedViewModel: feedViewModel)) //после срабатывания метода мы попадаем в файл viewController
        case .presentUserInfo(user: let user):
            let userViewModel = UserViewModel.init(photoUrlString: user?.photo100)
            viewController?.displayData(viewModel: .displayUserInfo(userViewModel: userViewModel))
        }
    }
    
    //создами функицю которая будет преобразовывать поступающие в presenter данные типа FeedItem в модель данных для ячейки FeedViewModel.Cell
    private func cellViewModel(from feedItem: FeedItem, feedProfiles: [FeedProfile], feedGroups: [FeedGroup], revealedPostIds: [Int]) -> FeedViewModel.Cell {
        
        //получаем данные профиля, который опубликовал новость
        let profile = self.profile(for: feedItem.sourceId, feedProfiles: feedProfiles, feedGroups: feedGroups)!
        
        let photoAttachments = self.photoAttachments(feedItem: feedItem)
        
        //преобразуем в красивый формат дату которая лежит в feedItem
        let date = Date(timeIntervalSince1970: feedItem.date)
        let dateTitle = dateFormatter.string(from: date)
        
        let isFullSized = revealedPostIds.contains { (postId) -> Bool in
            return postId == feedItem.postId
        }
        
        //получаем размеры текста и изображения с помощью функции, которая располагается в объекте
        let sizes = cellLayoutCalculator.sizes(postText: feedItem.text, photoAttachments: photoAttachments, isFullSizePost: isFullSized)
    
        
        return FeedViewModel.Cell.init(postId: feedItem.postId,
                                       iconUrlString: profile.photo,
                                       name: profile.name,
                                       date: dateTitle,
                                       text: feedItem.text,
                                       likes: formattedCounter(feedItem.likes?.count),
                                       comments: formattedCounter(feedItem.comments?.count),
                                       shares: formattedCounter(feedItem.reposts?.count),
                                       views: formattedCounter(feedItem.views?.count),
                                       photoAttachments: photoAttachments,
                                    sizes: sizes)
    }
    
    //создаем функцию для отработки визуальных изменений значений
    private func formattedCounter(_ counter: Int?) -> String? {
        guard let counter = counter, counter > 0 else {return nil}
        var counterString = String(counter)
        //преображение числа
        if 4...6 ~= counterString.count {
            counterString = String(counterString.dropLast(3)) + "K"
        } else if counterString.count > 6 {
            counterString = String(counterString.dropLast(6)) + "M"
        }
        
        return counterString
    }
    
    
    //создаим функцию для поиска в массиве нужного для определенной новости профиля, и возврата его для заполнения ячейки
    private func profile(for sourceId: Int, feedProfiles: [FeedProfile], feedGroups: [FeedGroup]) -> ProfileRepresentable? {
        //в зависимости от знака sourceId определяем массив где будем искать
        let profilesOrGroups: [ProfileRepresentable] = sourceId >= 0 ? feedProfiles : feedGroups
        //приводим к нормальному положительному id для дальнейшего поиска
        let normalSourceId = sourceId >= 0 ? sourceId : -sourceId
        //получаем из выбранного на первой строке массива первый профиль подходящий под id
        let profileRepresentable = profilesOrGroups.first { (myProfileRepresentable) -> Bool in
            myProfileRepresentable.id == normalSourceId
        }
        return profileRepresentable
    }
    
    private func photoAttachment(feedItem: FeedItem) -> FeedViewModel.FeedCellPhotoAttachment? {
        // функция compactMap пробегается по массиву attachments и если она находит там параметр photo то добавляет в массив
        guard let photos = feedItem.attachments?.compactMap({ (attachment) in
            attachment.photo
        }), let firstPhoto = photos.first else {  //из массива фотографий сформированных ранее, мы берем первую
            return nil
        }
        return FeedViewModel.FeedCellPhotoAttachment.init(photoUrlString: firstPhoto.srcBIG, width: firstPhoto.width, height: firstPhoto.heiht)
    }
    
    private func photoAttachments(feedItem: FeedItem) -> [FeedViewModel.FeedCellPhotoAttachment] {
        guard let attachments = feedItem.attachments else {return []}
        
        return attachments.compactMap ({ (attachment) -> FeedViewModel.FeedCellPhotoAttachment? in
            guard let photo = attachment.photo else { return nil }
            return FeedViewModel.FeedCellPhotoAttachment.init(photoUrlString: photo.srcBIG, width: photo.width, height: photo.heiht)
        })
    }
    
}
