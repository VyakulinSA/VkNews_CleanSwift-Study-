//
//  String + Height.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 20.01.2021.
//

import Foundation
import UIKit

//делаем расширение типа String для подсчета высоты текста в файле NewsfeeedCellLayoutCalculator
extension String {
    func height(labelWidth: CGFloat, font: UIFont) -> CGFloat{
        let textSize = CGSize(width: labelWidth, height: .greatestFiniteMagnitude)
        
        let size = self.boundingRect(with: textSize,
                                     options: .usesLineFragmentOrigin,
                                     attributes: [NSAttributedString.Key.font : font],
                                     context: nil)
        return ceil(size.height)
    }
}
