//
//  TitleView.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 26.01.2021.
//

import Foundation
import UIKit

protocol TitleViewViewModel {
    var photoUrlString: String? {get}
}

//создаем кастомный тайтл на навигейшн баре

class TitleView: UIView {
    
    //создадим свойства для хранения изображения и тд
    
    private var myTextField = InsetableTextField()
    
    
    private var myAvatarView: WebImageView = {
        let imageview = WebImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.backgroundColor = .orange
        imageview.clipsToBounds = true
        return imageview
    }()
    
    //стандартное начало иницализатора
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(myTextField)
        addSubview(myAvatarView)
        makeConstraints()
    }
    
    func set(userViewModel: TitleViewViewModel) {
        myAvatarView.set(imgeURL: userViewModel.photoUrlString)
    }
    
    private func makeConstraints() {
        // myAvatarView constraints
        myAvatarView.anchor(top: topAnchor,
                            leading: nil,
                            bottom: nil,
                            trailing: trailingAnchor,
                            padding: UIEdgeInsets.init(top: 4, left: 777, bottom: 777, right: 4))
        myAvatarView.heightAnchor.constraint(equalTo: myTextField.heightAnchor, multiplier: 1).isActive = true
        myAvatarView.widthAnchor.constraint(equalTo: myTextField.heightAnchor, multiplier: 1).isActive = true
        
        // myTextField constraints
        myTextField.anchor(top: topAnchor,
                           leading: leadingAnchor,
                           bottom: bottomAnchor,
                           trailing: myAvatarView.leadingAnchor,
                           padding: UIEdgeInsets.init(top: 4, left: 4, bottom: 4, right: 12))
    }
    
    //чтобы элементы распологаемые на навигейшнбаре подстраивались под него, используют следующую функцию
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        myAvatarView.layer.masksToBounds = true
        myAvatarView.layer.cornerRadius = myAvatarView.frame.width / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
