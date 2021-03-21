//
//  RowLayout.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 24.01.2021.
//


//класс для настройки собственного layout, чтобы отображать изображения по нашим принципам
import Foundation
import UIKit

protocol RowLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, photoAtIndexPath indexPath: IndexPath) -> CGSize
}

//класс который подключаем в CollectionView чтобы настроить отображение
class RowLayout: UICollectionViewLayout {
    weak var delegate: RowLayoutDelegate! //делегат, для выполнения функций из другого класса
    
    static var numbersOfRows = 1 //кол-во строк в коллекции
    fileprivate var cellPadding: CGFloat = 8 //отступы от краев
    
    //для того, чтобы не высчитывать повторно размеры layout, будем его складывать в кэш и потом запрашивать
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    //contentWidth и contentHeight - размеры прямоугольника в котором будет отображаться контент (мы его динамически выщитываем)
    fileprivate var contentWidth: CGFloat = 0
    //константа
    //высчитываем высоту на основе контента внутри ячейки
    fileprivate var contentHeight: CGFloat {
        guard let collectionView = collectionView else {return 0}
        
        let insets = collectionView.contentInset
        return collectionView.bounds.height - (insets.left + insets.right)
    }
    
    //после расчета contentWidth и contentHeight мы их передаем в функцию, которая отображает нам размер содержимого
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    //подготовка layout
    override func prepare() {
        contentWidth = 0 //для новой ячейки обнуляем максимальную ширину контента
        cache = [] //обнуляем кэш, для каждой новой ячейки
        //проверяем что кэш пустой(потому что если не пустой, то возможно нам не надо подготавливать и расчитывать все) и у нас есть представлении коллекции
        guard cache.isEmpty == true, let collectionView = collectionView else {return}
        //массив для хранения размеров всех фотографий
        var photos = [CGSize]()
        //достаем и записываем все размеры фотографий которые распологаются в collectionView
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let photoSize = delegate.collectionView(collectionView, photoAtIndexPath: indexPath)
            photos.append(photoSize)
        }
        
        let superviewWidth = collectionView.frame.width
        
        //находим фотографию с самым маленьким расширением из всей коллекции переданных, и выбираем ее высоту для всех элементов коллекции
        guard  var rowHeight = RowLayout.rowHeightCounter(superviewWidth: superviewWidth, photosArray: photos) else {return}
        
        rowHeight = rowHeight / CGFloat(RowLayout.numbersOfRows)
        
        //массив содержащий соотношение сторон для каждой фотографии
        let photosRatios = photos.map {$0.height / $0.width } //для каждой фотографии находим соотношение сторон
        
        //зафиксируем вертикальные координаты
        var yOffset = [CGFloat]()
        for row in 0 ..< RowLayout.numbersOfRows {
            yOffset.append(CGFloat(row) * rowHeight) //в зависимости от кол-ва строк определяем вертикальную координату расположения картинки
        }
        
        var xOffset = [CGFloat](repeating: 0, count: RowLayout.numbersOfRows) //горизонтально всегда будет от 0 идти
        
        var row = 0 //нумерация строк
        
        //работаем с каждым элементом в секции, для каждой ячейки задаем собственный размер, фиксируем ее расположение(yOffset и xOffset)
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0) //определяем индекс
            let ratio = photosRatios[indexPath.row] //определяем соотношение сторон
            let width = rowHeight / ratio //для каждого элемента мы уже знаем максимально допустимую высоту, поэтому определяем ширину через соотношение сторон
            let frame = CGRect(x: xOffset[row], y: yOffset[row], width: width, height: rowHeight) //определяем расположение элемента
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding) //указываем отступы
            
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath) //создаем атрибут по определенному индексу, который положим в кэш
            attribute.frame = insetFrame //присваиваем атрибуту фрэйм
            cache.append(attribute) //складываем в кэш
            
            contentWidth = max(contentWidth, frame.maxX) //расширяем размер contentView для отображения всех картинок
            xOffset[row] = xOffset[row] + width //расширяем xOffset, чтобы следующий элемент распологался дальше
            row = row < (RowLayout.numbersOfRows - 1) ? (row + 1) : 0
        }
    }
    

    //MARK: Данные методы пишем всегда
    //Шаблонный код, который можно переиспользовать в проектах
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        //перебераем атрибуты в кэше и проверяем является ли данный атрибут сейчас у польщователя на экране и если это так, то добавляем эти атрибуты в специальный массив, который возвращаем.
        //И уже этот массив с видимыми атрибутами и видит наш пользователь
        for attribute in cache {
            if attribute.frame.intersects(rect) {
                visibleLayoutAttributes.append(attribute)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.row]
    }
    
    
    //функция для фозврата максимально подходящей в зависимости от разных размеров фото высоты строки
    static func rowHeightCounter(superviewWidth: CGFloat, photosArray: [CGSize]) -> CGFloat? {
        var rowHeight: CGFloat
        
        //получаем фото с наименьшим соотношением сторон, чтобы по нему определять все остальные фотографии и все выглядело лаконично
        let photoWithMinRatio = photosArray.min { (first, second) -> Bool in
            (first.height / first.width) < (second.height / second.width)
        }
        
        guard let myPhotoWithMinRatio = photoWithMinRatio else {return nil}
        //сравним ширину экрана, с шириной фотографии которая имеет наименьше соотношение сторон, чтбы фотография не выходила за рамки экрана
        //получаем разницу между размерами
        let difference = superviewWidth / myPhotoWithMinRatio.width
        
        rowHeight = myPhotoWithMinRatio.height * difference
        
        rowHeight = rowHeight * CGFloat(RowLayout.numbersOfRows)
        return rowHeight
    }
    
    
}
