//
//  NewsfeedViewController.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 08.01.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol NewsfeedDisplayLogic: class {
    func displayData(viewModel: NewsfeedModels.Model.ViewModel.ViewModelData)
}

class NewsfeedViewController: UIViewController, NewsfeedDisplayLogic, NewsfeedCodeCellDelegate {
    
    
    var interactor: NewsfeedBusinessLogic?
    var router: (NSObjectProtocol & NewsfeedRoutingLogic)?
    
    
    
    //создадим свойство для хранения ViewModel для отображения экрана и ячеек
    private var feedViewModel = FeedViewModel.init(cells: [])
    
    //создаем outlet для работы с tableView который находится на экране (через него будем создавать ячейки и делать остальную дичь)
    @IBOutlet weak var table: UITableView!
    //создаем свойство для работы с titleView
    private var titleView = TitleView()
    
    //создаем свойство для работы с индикатором обновления страницы
    private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        //добавим наблюдателя для включения функции если значение меняется
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    //Так как мы создаем собственный storyboard, удаляем нижеидущий код и прописываем метод setup() во ViewDidLoad
    // MARK: Object lifecycle
    
    //  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    //    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    //    setup()
    //  }
    //
    //  required init?(coder aDecoder: NSCoder) {
    //    super.init(coder: aDecoder)
    //    setup()
    //  }
    
    // MARK: Setup
    
    private func setup() {
        let viewController        = self
        let interactor            = NewsfeedInteractor()
        let presenter             = NewsfeedPresenter()
        let router                = NewsfeedRouter()
        viewController.interactor = interactor
        viewController.router     = router
        interactor.presenter      = presenter
        presenter.viewController  = viewController
        router.viewController     = viewController
    }
    
    // MARK: Routing
    
    
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTopBars() //подключаем навигейшнбар
        setupTable()
        view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        
        
        //вызываем interactor при загрузке страницы, чтобы он сразу шел получать данные и запускал цикл ViewController - Interactor - Presetnter - ViewController
        interactor?.makeRequest(request: NewsfeedModels.Model.Request.RequestType.getNewsfeed)
        interactor?.makeRequest(request: .getUser)
        
    }
    
    private func setupTable() {
        let topInset: CGFloat = 8 //делаем отсут сверху
        table.contentInset.top = topInset
        //подключаем ячейку спроектированную через xib файл
        table.register(UINib(nibName: "NewsfeedCell1", bundle: nil), forCellReuseIdentifier: NewsfeedCell.reusedID)
        //подключаем ячейку которую создаем через код
        table.register(NewsfeedCodeCell.self, forCellReuseIdentifier: NewsfeedCodeCell.reuseId)
        //производим настройку представления таблицы
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.addSubview(refreshControl)
    }
    
    
    //функция для расположения на NavigationBar кастомного TitleView(см. одноименный класс)
    private func setupTopBars() {
        self.navigationController?.hidesBarsOnSwipe = true //скрывать наигейшнбар когда листаем вниз
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.titleView = titleView
    }
    
    //селектор для выполнения функции refreshControl
    @objc private func refresh() {
        //так как при рефреше мы хотим обновить новостную ленту, мы вызываем тот же метод запроса новостей как при первоначальной загрузке приложения
        interactor?.makeRequest(request: .getNewsfeed)
        
    }
    
    func displayData(viewModel: NewsfeedModels.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayNewsfeed(feedViewModel: let feedViewModel):
            //присваиваем viewModel в свойство viewModel данного класса
            self.feedViewModel = feedViewModel
            //перезагружаем таблицу, чтобы наши данные обновились, т.к. данные в функцию приходят после того, как загрузилась ViewDidLoad
            table.reloadData() //запускаем reload и запускаются функции DataSource и Delegate у таблицы (см. ниже extention)
            refreshControl.endRefreshing() //отключаем крутящийся спинер загрузки
        case .displayUserInfo(userViewModel: let userViewModel):
            titleView.set(userViewModel: userViewModel)
        }
        
    }
    
    //MARK:NewsfeedCodeCellDelegate
    func revealPost(for cell: NewsfeedCodeCell) {
        //узнаем номер ячейки текст которой хотим раскрыть
        guard let indexPath = table.indexPath(for: cell) else {return}
        //получаем всю информацию, которая содержится в ячейке
        let cellViewModel = feedViewModel.cells[indexPath.row]
        
        interactor?.makeRequest(request: NewsfeedModels.Model.Request.RequestType.revealPostIds(postId: cellViewModel.postId))
    }
    
}

//создадим расширение для работы с таблицей
extension NewsfeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedViewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: NewsfeedCell.reusedID, for: indexPath) as! NewsfeedCell
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsfeedCodeCell.reuseId, for: indexPath) as! NewsfeedCodeCell
        //отображение информации в ячейке будет происходить с помощью метода set (см контроллер ячейки) + модель данных передаваемую туда (которую мы по идее получаем от Presenter)
        //достаем из ViewModel массива ячеек, нужную нам ячейку
        let cellViewModel = feedViewModel.cells[indexPath.row]
        //наполняем View для каждой ячейки
        cell.set(viewModel: cellViewModel)
        cell.delegate = self

        return cell
    }
    
    //установим высоту ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //достаем из ViewModel массива ячеек, нужную нам ячейку
        let cellViewModel = feedViewModel.cells[indexPath.row]
        //достаем значение размера всей ячейки
        return cellViewModel.sizes.totalHeight
//        return 212
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellViewModel = feedViewModel.cells[indexPath.row]
        return cellViewModel.sizes.totalHeight
    }
    
    
}


