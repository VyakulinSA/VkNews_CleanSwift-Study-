//
//  NewsfeedCell.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 08.01.2021.
//

import Foundation
import UIKit

//контроллер для ячейки
class NewsfeedCell: UITableViewCell {
    
    //идентификатор ячейки (делаем статик, чтобы всегда был один для данной ячейки)
    static let reusedID = "NewsfeedCell"
    
    var delegate: NewsfeedCodeCellDelegate?
    
    //выводим оутлеты от xib ячейки
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var iconImageView: WebImageView! //указываем тип, не как обычно UIImageView а специальный класс
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var postImageView: WebImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    @IBOutlet weak var bottomView: UIView!

    //функция для многократного переиспользования ячейки
    override func prepareForReuse() {
        iconImageView.set(imgeURL: nil)
        postImageView.set(imgeURL: nil)
    }
    
    
    
    //    функция для отрисовки ячейки
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //округляем ячейки
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImageView.clipsToBounds = true
        
        //округляем углы общего View ячейки
        cardView.layer.cornerRadius = 10
        cardView.clipsToBounds = true
        
        //производим настройку вида ячейки (задний фон пустой, выделение ячеек не производится
        backgroundColor = .clear
        selectionStyle = .none
        
    }
    
//    создаем функцию которая будет наполнять элементы данными
//    func set(viewModel: FeedCellViewModel) {
//        //вызываем метод для обновления изображения во view
//        iconImageView.set(imgeURL: viewModel.iconUrlString)
//        nameLabel.text = viewModel.name
//        dateLabel.text = viewModel.date
//        postLabel.text = viewModel.text
//        likesLabel.text = viewModel.likes
//        commentsLabel.text = viewModel.comments
//        shareLabel.text = viewModel.shares
//        viewsLabel.text = viewModel.views
//        
//        postLabel.frame = viewModel.sizes.postLabelFrame
//        postImageView.frame = viewModel.sizes.attachmentFrame
//        bottomView.frame = viewModel.sizes.bottomViewFrame
//        
//        //если в модели данных приходит ссылка на изображение, то подгружаем его и отображаем
//        if let photoAttachment = viewModel.photoAttachments {
//            postImageView.set(imgeURL: photoAttachment.photoUrlString)
//            postImageView.isHidden = false
//        } else {
//            //если изображения не оказалось, скрываем imageview
//            postImageView.isHidden = true
//        }
//        
//    }
}
