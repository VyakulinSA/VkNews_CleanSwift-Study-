//
//  Constants.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 21.01.2021.
//

import Foundation
import UIKit

//структура с константными значениями элементов ячейки (см. xib файл и отступы элементов на нем) (для динамического закрепления и изменения)
struct Constants {
    static let cardInsets = UIEdgeInsets(top: 0, left: 8, bottom: 12, right: 8) //отступы у cardView
    static let topViewHeight: CGFloat = 36 //высота
    static let postLabelInsets = UIEdgeInsets(top: 8+Constants.topViewHeight + 8, left: 8, bottom: 8, right: 8) //отступы у postLabel
    static let postLabelFont = UIFont.systemFont(ofSize: 15) //размер шрифта
    static let bottomViewHeight: CGFloat = 50
    //размеры viw которые используются для расположения в них лайков репостов и тд
    static let bottomViewViewHeight: CGFloat = 50
    static let bottomViewViewWidth: CGFloat = 80
    //размеры для картинок распологаемых в buttomView
    static let bottomViewViewsIconSize: CGFloat = 24
    //параметры для отображения кнопки "показать больше" кол-во строк и тд
    static let minifiedPostLimitLines: CGFloat = 8
    static let minifiedPostLines: CGFloat = 6
    static let moreTextButtonSize = CGSize(width: 170, height: 30)
    static let moreTextButtonInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
}
