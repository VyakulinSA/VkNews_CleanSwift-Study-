//
//  GalleryCollectionViewCell.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 23.01.2021.
//

import Foundation
import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "GalleryCollectionViewCell"
    //вьюха с изобраением в котором будет отображать фото
    let myImageView: WebImageView = {
        let imageView = WebImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill //Растягиваем изображение на всю вьюху, иначе будут видны края
        imageView.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8980392157, blue: 0.9098039216, alpha: 1)
        return imageView
    }()
    //инициализация самой ячейки коллекции
    override init(frame: CGRect) {
        super.init(frame: frame)

        //добавляем в ячейку вьюху с изображением
        addSubview(myImageView)
        //myImageView constraints
        myImageView.fillSuperview()
    }
    //делаем ячейки переиспользуемыми
    override func prepareForReuse() {
        myImageView.image = nil
    }
    //установить изображение
    func set(imageUrl: String?) {
        myImageView.set(imgeURL: imageUrl)
    }
    
    //MARK: Работа с внешним видом
    override func layoutSubviews() { //корректировки интерфейса желательно проделывать в данной функции
        super.layoutSubviews()
        
        myImageView.layer.masksToBounds = true
        myImageView.layer.cornerRadius = 10
        self.layer.shadowRadius = 3
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 2.5, height: 4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
