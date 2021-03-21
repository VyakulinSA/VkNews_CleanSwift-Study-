//
//  NewsfeedCodeCell.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 21.01.2021.
//

import Foundation
import UIKit

//создаем протокол со свойствами, которыми должна обладать наша ячейка, чтобы потом подписать под данный протокол ViewModel и сказать, что она должна нести в себе данные свойства
protocol FeedCellViewModel {
    var iconUrlString: String { get }
    var name: String { get }
    var date: String { get }
    var text: String? { get }
    var likes: String? { get }
    var comments: String? { get }
    var shares: String? { get }
    var views: String? { get }
    //добавляем свойство которое будет хранить информацию о изображении
    var photoAttachments: [FeedCellPhotoAttachmentViewModel] {get} //так как у катинке есть несколько параметров, создаем для нее отдельный протокол
    var sizes: FeedCellSizes {get}
}

protocol FeedCellSizes {
    var postLabelFrame: CGRect {get} //размер текста
    var attachmentFrame: CGRect {get} //размер изображения
    var bottomViewFrame: CGRect {get} //размер нижнего бара ячейки
    var totalHeight: CGFloat {get} //общая высота ячейки в целом
    var moreTextButtonFrame: CGRect {get} //размер и полодение кнопки "показать больше"
    
}

protocol  FeedCellPhotoAttachmentViewModel {
    var photoUrlString: String? {get}
    var width: Int {get}
    var height: Int {get}
}

//Создаем протокол чтобы связать NewsfeedCodeCell и NewsfwwdViewController и обмениваться данными
protocol NewsfeedCodeCellDelegate: class {
    func revealPost(for cell: NewsfeedCodeCell)
}

//создаем класс нашей ячейки
final class NewsfeedCodeCell: UITableViewCell {
    //сохраняем в ней идентификатор для дальнейшей регистрации в таблице
    static let reuseId = "NewsfeedCodeCell"
    
    weak var delegate: NewsfeedCodeCellDelegate?
    
    //Создаем слоя которые потом будем размещать друг на друга в ячейке
    //MARK: First Layer
    //создадим элемент view и сразу его инициализируем
    let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //говорим компилятору, что данное view можно закреплять на экране
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: Second Layer
    //создадим элемент topView(где распологаются инфо с названием и датой) view и настроим его
    let topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        return view
    }()
    
//    //Label для размещения текста поста
//    let postLabel: UILabel = {
//        let label = UILabel()
//        //если размер основной view на которой будет распологаться элемент задаются динамически, то translatesAutoresizingMaskIntoConstraints ведет себя некорректно, в данном случае убираем ее
//        //        label.translatesAutoresizingMaskIntoConstraints = false
//        label.numberOfLines = 0
//        label.font = Constants.postLabelFont
//        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
////        label.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
//        return label
//    }()
    
    let postLabel: UITextView = {
        let textView = UITextView()
        textView.font = Constants.postLabelFont
        textView.isScrollEnabled = false
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        
        let padding = textView.textContainer.lineFragmentPadding
        textView.textContainerInset = UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: -padding)
        
        textView.dataDetectorTypes = .all
        return textView
    }()
    
    //UIButton для скрытия и раскрытия длинного текста
    let moreTextButton: UIButton = {
       let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(#colorLiteral(red: 0.4, green: 0.6235294118, blue: 0.831372549, alpha: 1), for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentVerticalAlignment = .center
        button.setTitle("Показать полностью...", for: .normal)
        
        return button
    }()
    
    let galleryCollectionView = GalleryCollectionView()
    
    //UIImage для размещения изображения поста
    let postImageView: WebImageView = {
        let imageView = WebImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        return imageView
    }()
    //view для размещения нижнего поля с информацией
    let bottomView: UIView = {
        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        return view
    }()
    
    //MARK: Third Layer on topView
    
    let iconImageView: WebImageView = {
        let imageView = WebImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//        label.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
//        label.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        return label
    }()
    
    //MARK: Third Layer on bottomView
    let likesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        return view
    }()
    
    let commentsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        return view
    }()
   
    let sharesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        return view
    }()

    let viewViews: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        return view
    }()
    
    //MARK: Four Layer on bottomView
    let likesImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "like")
        return imageView
    }()
    
    let commentsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "comment")
        return imageView
    }()
    
    let sharesImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "share")
        return imageView
    }()
    
    let viewsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "eye")
        return imageView
    }()
    
    let likesLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "457K"
        label.textColor = #colorLiteral(red: 0.5058823529, green: 0.5490196078, blue: 0.6, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.lineBreakMode = .byClipping
        return label
    }()
    
    let commentsLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.5058823529, green: 0.5490196078, blue: 0.6, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.lineBreakMode = .byClipping
        return label
    }()
    
    let sharesLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.5058823529, green: 0.5490196078, blue: 0.6, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.lineBreakMode = .byClipping
        return label
    }()
    
    let viewsLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.5058823529, green: 0.5490196078, blue: 0.6, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.lineBreakMode = .byClipping
        return label
    }()
    
//    функция для многократного переиспользования ячейки
    override func prepareForReuse() {
        iconImageView.set(imgeURL: nil)
        postImageView.set(imgeURL: nil)
    }
    
    
    //MARK: Init
    //переиспользуем инициализаотр (тк мы наследуемся)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        //ключевое слово super служит для того, чтобы использовать метод init суперкласса (от которого наследуемся (UITableViewCell))
        //в данном конкретном примере это означает, что мы создаем класс ячейки, который наследуется от UITableViewCell
        //мы переопределяем инициализатор суперкласса(ключевое слово override), и хотим его модернизировать и изменить (что то добавить)
        //но мы хотим, чтобы инициаизация самой ячейки (какие то стандартные методы под капотом) производились как и в суперкалссе
        //поэтому мы обращаемся к init суперкласса, вызываем его, а ниже уже модернизируем наш собственный класс для конкретной ячейки
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear //ВАЖНО: установить .clear, чтобы superView ячейки не закрывало view таблицы(background указан в файле NewsfeedViewController)
        //ВАЖНО: .clear - делает superView ячейки прозрачным, и мы видим цвет view от таблицы либо можно установить цвет, но он будет везде
        selectionStyle = .none
        
        
        cardView.layer.cornerRadius = 10
        cardView.clipsToBounds  = true
        
        iconImageView.layer.cornerRadius = Constants.topViewHeight / 2
        iconImageView.clipsToBounds = true
        //Дадим действие для кнопки
        moreTextButton.addTarget(self, action: #selector(moreTextButtonToouch), for: .touchUpInside)
        //размещаем в ячейке первый слой view содаржащий настройки cardView через специальную функцию с настройками
        overlayFirstLayer()
        //размещаем в ячейке второй слой view содаржащий настройки элементов которые лежат поверх cardView через специальную функцию с настройками
        overlaySecondLayer()
        //размещаем третий слой view на topview
        overlayThirdLayerOnTopView()
        //размещаем третий слой view на bottomView - те самые view в которых будут распологаться изображение и колво лайков просмотров и тд
        overlayThirdLayerOnBottomView()
        //размещаем четвертый слой view на bottomView - те самые view с изображением и колвом лайков просмотров и тд
        overlayFourthLayerOnBottomViewViews()
    }
    
    
    @objc func moreTextButtonToouch() {
        delegate?.revealPost(for: self)
    }
    
    
    //    создаем функцию которая будет наполнять элементы данными
    func set(viewModel: FeedCellViewModel) {
        //вызываем метод для обновления изображения во view
        iconImageView.set(imgeURL: viewModel.iconUrlString)
        nameLabel.text = viewModel.name
        dateLabel.text = viewModel.date
        postLabel.text = viewModel.text
        likesLabel.text = viewModel.likes
        commentsLabel.text = viewModel.comments
        sharesLabel.text = viewModel.shares
        viewsLabel.text = viewModel.views
        postLabel.frame = viewModel.sizes.postLabelFrame

        bottomView.frame = viewModel.sizes.bottomViewFrame
        moreTextButton.frame = viewModel.sizes.moreTextButtonFrame
        
        //если в модели данных приходит ссылка на изображение, то подгружаем его и отображаем
        //если одно
        if let photoAttachment = viewModel.photoAttachments.first, viewModel.photoAttachments.count == 1 {
            postImageView.set(imgeURL: photoAttachment.photoUrlString) //обновляем view
            postImageView.isHidden = false //показываем view
            galleryCollectionView.isHidden = true //скрываем collectionView
            postImageView.frame = viewModel.sizes.attachmentFrame //размеры в соответствии с фото
        //если больше одной фотографии
        }else if viewModel.photoAttachments.count > 1{
            galleryCollectionView.frame = viewModel.sizes.attachmentFrame //настраиваем так же на основе перфой фотографии (позже будет исправлено для каждой свой размер
            postImageView.isHidden = true //скрываем view для отображения одной фотографии
            galleryCollectionView.isHidden = false //показываем collectionView для отображения нескольких фото
            galleryCollectionView.set(photos: viewModel.photoAttachments) //обновляем collectionView
        }else {
            //если изображения не оказалось, скрываем все view
            postImageView.isHidden = true
            galleryCollectionView.isHidden = true
        }
        
    }
    
    //MARK: Funcs to fill and create Constraints for layers
    //функция для настройки и размещения cardView - 1 слой
    private func overlayFirstLayer() {
        //добавляем view в ячейку, это происходит при нициализации, когда ячейка отрисовывается, у нас выполняется код
        contentView.addSubview(cardView)
        //cardView constraints
        cardView.fillSuperview(padding: Constants.cardInsets)
    }
    
    private func overlaySecondLayer() {
        cardView.addSubview(topView)
        cardView.addSubview(postLabel)
        cardView.addSubview(moreTextButton)
        cardView.addSubview(postImageView)
        cardView.addSubview(galleryCollectionView)
        cardView.addSubview(bottomView)
        
        //topView Constraints
        topView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8).isActive = true
        topView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8).isActive = true
        topView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8).isActive = true
        topView.heightAnchor.constraint(equalToConstant: Constants.topViewHeight).isActive = true
        
        //postLabel Constraints - создаются автоматически через класс NewsfeedCellLayoutCalculator
        //moreTextButton Constraints - создаются автоматически через класс NewsfeedCellLayoutCalculator
        //postImageView Constraints - создаются автоматически через класс NewsfeedCellLayoutCalculator
        //bottomView Constraints - создаются автоматически через класс NewsfeedCellLayoutCalculator
    }
    
    private func overlayThirdLayerOnTopView() {
        topView.addSubview(iconImageView)
        topView.addSubview(nameLabel)
        topView.addSubview(dateLabel)
        
        //iconImageView constraints
        iconImageView.leadingAnchor.constraint(equalTo: topView.leadingAnchor).isActive = true
        iconImageView.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: Constants.topViewHeight).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: Constants.topViewHeight).isActive = true
        
        //nameLabel constraints
        nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 5).isActive = true
        nameLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 3).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -5).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: Constants.topViewHeight / 2 - 4).isActive = true //благодаря тому, что мы размер лэйбла привязваем к размеру topView на котором он располагается, то в этом случае при изименении topView у нас пропорционально все изменяется
        
        //dateLabel constraints
        dateLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 5).isActive = true
        dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -5).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 13).isActive = true
    }
    
    private func overlayThirdLayerOnBottomView() {
        bottomView.addSubview(likesView)
        bottomView.addSubview(commentsView)
        bottomView.addSubview(sharesView)
        bottomView.addSubview(viewViews)
        
        
        //likesView constraints
        likesView.anchor(top: bottomView.topAnchor,
                         leading: bottomView.leadingAnchor,
                         bottom: nil,
                         trailing: nil,
                         size: CGSize(width: Constants.bottomViewViewWidth, height: Constants.bottomViewViewHeight))
        //commentsView constraints
        commentsView.anchor(top: bottomView.topAnchor,
                         leading: likesView.trailingAnchor,
                         bottom: nil,
                         trailing: nil,
                         size: CGSize(width: Constants.bottomViewViewWidth, height: Constants.bottomViewViewHeight))
        //sharesView constraints
        sharesView.anchor(top: bottomView.topAnchor,
                         leading: commentsView.trailingAnchor,
                         bottom: nil,
                         trailing: nil,
                         size: CGSize(width: Constants.bottomViewViewWidth, height: Constants.bottomViewViewHeight))
        //viewViews constraints
        viewViews.anchor(top: bottomView.topAnchor,
                         leading: nil,
                         bottom: nil,
                         trailing: bottomView.trailingAnchor,
                         size: CGSize(width: Constants.bottomViewViewWidth, height: Constants.bottomViewViewHeight))
    }
    
    private func overlayFourthLayerOnBottomViewViews() {
        likesView.addSubview(likesImage)
        likesView.addSubview(likesLabel)
        
        commentsView.addSubview(commentsImage)
        commentsView.addSubview(commentsLabel)
        
        sharesView.addSubview(sharesImage)
        sharesView.addSubview(sharesLabel)
        
        viewViews.addSubview(viewsImage)
        viewViews.addSubview(viewsLabel)
        
        helpInFourthLayer(view: likesView, imageView: likesImage, label: likesLabel)
        helpInFourthLayer(view: commentsView, imageView: commentsImage, label: commentsLabel)
        helpInFourthLayer(view: sharesView, imageView: sharesImage, label: sharesLabel)
        helpInFourthLayer(view: viewViews, imageView: viewsImage, label: viewsLabel)
        
    }
    
    //создадим функцию для настройки одинаковых констрейнтов (делается для того, потому что у нас в 4 вьюхах одинаково все)
    private func helpInFourthLayer(view: UIView, imageView: UIImageView, label: UILabel) {
        //imageView Constraints
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.bottomViewViewsIconSize).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: Constants.bottomViewViewsIconSize).isActive = true
        
        //label Constraints
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 5).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

////P3. (ВАЖНО: данный код, можно переносить из файла в файл, для подключения SwiftUI к UIKit) Стандартно UIKit не может работать через Canvas с экраном как при работе через SwiftUI. Ддля того, чтобы это стало возможно, нужно переконвертировать UIKit через SwiftUI
////Импортируем SwiftUI библиотеку
//import SwiftUI
////создаем структуру
//struct ViewControllerProvider: PreviewProvider {
//    static var previews: some View {
//            ContainerView().edgesIgnoringSafeArea(.all)
//    }
//    
//    struct ContainerView: UIViewControllerRepresentable {
//        //создадим объект класса, который хотим показывать в Canvas
//        let viewController = NewsfeedCodeCell()
//        //меняем input параметры в соответствии с образцом
//        func makeUIViewController(context: UIViewControllerRepresentableContext<ViewControllerProvider.ContainerView>) -> NewsfeedCodeCell {
//            return viewController
//        }
//        //не пишем никакого кода
//        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        }
//    }
//}
