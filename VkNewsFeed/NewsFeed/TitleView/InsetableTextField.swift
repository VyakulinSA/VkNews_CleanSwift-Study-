//
//  InsetableTextField.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 26.01.2021.
//

import Foundation
import UIKit

class InsetableTextField: UITextField {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        placeholder = "Поиск"
        font = UIFont.systemFont(ofSize: 14)
        clearButtonMode = .whileEditing
        borderStyle  = .none
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let image = UIImage(named: "search")
        leftView = UIImageView(image: image)
        leftView?.frame = CGRect(x: 0, y: 0, width: 14, height: 14)
        leftViewMode = .always
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Увеличим расстояние между placeholder и изображением внутри TextField
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        rect.origin.x += 8
        return rect
//        return bounds.insetBy(dx: 36, dy: 0)
    }
    
    //Не понял для чего нужна функция, т.к. и так все хорошо работает
    
    //    override func textRect(forBounds bounds: CGRect) -> CGRect {
    //        var rect = super.textRect(forBounds: bounds)
    //        rect.origin.x += 8
    //        return rect
    ////        return bounds.insetBy(dx: 36, dy: 0)
    //    }
    
    //оттянуть картинку от левого края
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 12
        return rect
    }
}
