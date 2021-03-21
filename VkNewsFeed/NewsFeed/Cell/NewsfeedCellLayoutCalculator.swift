//
//  NewsfeedCellLayoutCalculator.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 19.01.2021.
//

import Foundation
import UIKit

struct Sizes: FeedCellSizes {
    var postLabelFrame: CGRect
    var moreTextButtonFrame: CGRect
    var attachmentFrame: CGRect
    var bottomViewFrame: CGRect
    var totalHeight: CGFloat
}



protocol FeedCellLayoutCalculatorProtocol {
    func sizes(postText: String?, photoAttachments: [FeedCellPhotoAttachmentViewModel], isFullSizePost: Bool) -> FeedCellSizes
}


//final используем для того, чтобы убрать возможность наследования от данного класса ,т.к. он будет содержать функцию для расчета параметров, и дополнительно никакого наследования не подразумевается
final class FeedCellLayoutCalculator: FeedCellLayoutCalculatorProtocol {
    
    private let screenWidth: CGFloat
    
    //по умолчанию инициализируем размерами экрана пользователя
    init(screenWidth: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)) {
        self.screenWidth = screenWidth
    }
    
    //функция для работы с размерами
    func sizes(postText: String?, photoAttachments: [FeedCellPhotoAttachmentViewModel], isFullSizePost: Bool) -> FeedCellSizes {
        
        var showMoreTextButton = false
        
        let cardViewWidth = screenWidth - Constants.cardInsets.left - Constants.cardInsets.right
        
        //MARK: Работа с postLabelFrame
        //origin - расположение нашего объекта (левый верхний угол) см. Constatnts значения
        var postLabelFrame = CGRect(origin: CGPoint(x: Constants.postLabelInsets.left, y: Constants.postLabelInsets.top), size: CGSize.zero)
        
        //работаем с размерами текста - если текст нам не пришел или пустой, то postLabelFrame - size так и остается равен CGSize.zero
        if let text = postText, !text.isEmpty {
            let width = cardViewWidth - Constants.postLabelInsets.left - Constants.postLabelInsets.right
            //текст есть, ширина есть, надо посчитать высоту нашего postLabel
            var height = text.height(labelWidth: width, font: Constants.postLabelFont)
            
            let limitHeiht = Constants.postLabelFont.lineHeight * Constants.minifiedPostLimitLines
            
            if !isFullSizePost && height > limitHeiht {
                height = Constants.postLabelFont.lineHeight * Constants.minifiedPostLines
                showMoreTextButton = true
            }
            
            postLabelFrame.size = CGSize(width: width, height: height)
        }
        
        //MARK: Работа с moreTextButtonFrame
        var moreTextButtonSize = CGSize.zero
        
        if showMoreTextButton {
            moreTextButtonSize = Constants.moreTextButtonSize
        }
        
        let moreTextButtonOrigin = CGPoint(x: Constants.moreTextButtonInsets.left, y: postLabelFrame.maxY)
        let moreTextButtonFrame = CGRect(origin: moreTextButtonOrigin, size: moreTextButtonSize)
        
        
        
        //MARK: Работа с attachmentFrame
        
        let attachmentTop = postLabelFrame.size == CGSize.zero ? Constants.postLabelInsets.top : moreTextButtonFrame.maxY + Constants.postLabelInsets.bottom
        
        var attachmentFrame = CGRect(origin: CGPoint(x: 0, y: attachmentTop), size: CGSize.zero)
//        if let attachment = photoAttachment {
//            let photoHeight: Float = Float(attachment.height) //приводим значение к типу Float
//            let photoWidtth: Float = Float(attachment.width)
//            let ratio = CGFloat(photoHeight / photoWidtth)//вычисляем соотношение сторон
//
//            //указываем ширину и высоту соттветствующую cardViewWidth с учетом соотношения сторон фотографии
//            attachmentFrame.size = CGSize(width: cardViewWidth, height: cardViewWidth * ratio)
//        }
        
        if let attachment = photoAttachments.first {
            let photoHeight: Float = Float(attachment.height) //приводим значение к типу Float
            let photoWidtth: Float = Float(attachment.width)
            let ratio = CGFloat(photoHeight / photoWidtth)//вычисляем соотношение сторон
            
            if photoAttachments.count == 1{
                //указываем ширину и высоту соттветствующую cardViewWidth с учетом соотношения сторон фотографии
                attachmentFrame.size = CGSize(width: cardViewWidth, height: cardViewWidth * ratio)
            } else if photoAttachments.count > 1{
                
                var photos = [CGSize]()
                for photo in photoAttachments {
                    let photoSize = CGSize(width: CGFloat(photo.width), height: CGFloat(photo.height))
                    photos.append(photoSize)
                }
                
                let rowHeight = RowLayout.rowHeightCounter(superviewWidth: cardViewWidth, photosArray: photos)
                attachmentFrame.size = CGSize(width: cardViewWidth, height: rowHeight!)

            }
        }
        
        //MARK: Работа с bottomViewFrame
        let bottomViewTop = max(postLabelFrame.maxY, attachmentFrame.maxY)
        
        let bottomViewFrame = CGRect(origin: CGPoint(x: 0, y: bottomViewTop), size: CGSize(width: cardViewWidth, height: Constants.bottomViewHeight))
        
        
        //MARK: Работа с totalHeight
        
        let totalHeight = bottomViewFrame.maxY + Constants.cardInsets.bottom
        
        return Sizes(postLabelFrame: postLabelFrame,
                     moreTextButtonFrame: moreTextButtonFrame,
                     attachmentFrame: attachmentFrame,
                     bottomViewFrame: bottomViewFrame,
                     totalHeight: totalHeight)
    }
}

