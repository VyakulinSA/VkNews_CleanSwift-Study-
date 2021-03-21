//
//  NewsfeedModels.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 08.01.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

//в данном файле - в перечислении - указываем нужные нам варианты действий при разных реквестах или респонзах и тд
enum NewsfeedModels {
   
  enum Model {
    struct Request {
      enum RequestType {
        case getNewsfeed
        case revealPostIds (postId: Int)
        case getUser
      }
    }
    struct Response {
      enum ResponseType {
        case presentNewsfeed(feed: FeedResponse, revealedPostIds: [Int])
        case presentUserInfo(user: UserResponse?)
      }
    }
    struct ViewModel {
      enum ViewModelData {
        case displayNewsfeed(feedViewModel: FeedViewModel)
        case displayUserInfo(userViewModel: UserViewModel)
      }
    }
  }
}

struct UserViewModel: TitleViewViewModel {
    var photoUrlString: String?

}

//создаем модель данных для отображения новостной ленты
    struct FeedViewModel {
        //вся модель данных для экрана, хранит в себе массив данных ячеек (в дальнейшем по indexPath будем вынимать)
        let cells: [Cell]
        
        struct Cell: FeedCellViewModel {
            var postId: Int
            
            var iconUrlString: String
            var name: String
            var date: String
            var text: String?
            var likes: String?
            var comments: String?
            var shares: String?
            var views: String?
            var photoAttachments: [FeedCellPhotoAttachmentViewModel]
            var sizes: FeedCellSizes
        }
        
        struct FeedCellPhotoAttachment: FeedCellPhotoAttachmentViewModel {
            var photoUrlString: String?
            var width: Int
            var height: Int
        }
        
    }
