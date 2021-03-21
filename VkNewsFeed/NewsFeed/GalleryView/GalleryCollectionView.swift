//
//  GalleryCollectionView.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 23.01.2021.
//

import Foundation
import UIKit
class GalleryCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //массив для заполнения фотографиями
    var photos = [FeedCellPhotoAttachmentViewModel]()
    

    //в данном случае пустой инициализатор используем потому, что не хотим, чтобы из вне на объекты GalleryCollectionView влияли и меняли frame и layout
    //вместо этого мы используем пустую инициализацию и  какбы хардкодим внутри настройки, и потом вызываем инициализатор суперкласса
    //потому что настройки у нас будут всегда одинаковые и мы их хардкодим (frame: .zero, collectionViewLayout: layout)
    init() {
        let rowLayout = RowLayout()
        super.init(frame: .zero, collectionViewLayout: rowLayout)
        
        delegate = self
        dataSource = self
        
        //MARK: Работа с внешним видом
        backgroundColor = UIColor.white
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: GalleryCollectionViewCell.reuseId)
        
        if let rowLayout = collectionViewLayout as? RowLayout {
            rowLayout.delegate = self
        }
    }
    //обновить вьюху коллекции, сохранить массив с фотографиями дял отображения
    func set(photos: [FeedCellPhotoAttachmentViewModel]) {
        self.photos = photos
        contentOffset = CGPoint.zero
        reloadData()//не завбываем обновить, чтобы отобразились все переданные фотографии
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.reuseId, for: indexPath) as! GalleryCollectionViewCell
        let urlPhoto = photos[indexPath.row].photoUrlString
        cell.set(imageUrl: urlPhoto)
        
        return cell
    }
    
//    //настройка размера ячейки внутри collectionView
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        //говорим, что ячейка должна совпадать с высотой и шириной самой collectionView
//        return CGSize(width: frame.width, height: frame.height)
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GalleryCollectionView: RowLayoutDelegate {
    
    
    
    func collectionView(_ collectionView: UICollectionView, photoAtIndexPath indexPath: IndexPath) -> CGSize {
        let width = photos[indexPath.row].width
        let height = photos[indexPath.row].height
        return CGSize(width: width, height: height)
    }
    
    
}
