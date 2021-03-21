//
//  SceneDelegate.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 06.01.2021.
//

import UIKit
import VKSdkFramework

class SceneDelegate: UIResponder, UIWindowSceneDelegate, AuthServiceDelegate {

    var window: UIWindow?
    //создадим свойство для работы с объектом класса AuthServices
    var authService: AuthService!
    
    //для того, чтобы у нас во всем проекте существовал только один authService и мы всю внутрянку имели относящуюся к одному объекту
    //сделаем singleTon
    
    static func shared() -> SceneDelegate {
        //сложная логика получения класса SceneDelegate
        //ниже указанные действия взяты со stackOverFlow
        let scene = UIApplication.shared.connectedScenes.first
        let sd: SceneDelegate = (((scene?.delegate as? SceneDelegate)!))
        return sd
    }


    //в данном методе работаем со сценами на экране
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //вместо стандартного guard пишем свой
//        guard let _ = (scene as? UIWindowScene) else { return }
        guard let windowScene = (scene as? UIWindowScene) else { return }
        //доставем свойство window из windowScene + сразу достаем границы сцены через coordinateSpace
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        //у свойства window достаем свойство windowScene и вставляем windowScene которую объявили выше
        window?.windowScene = windowScene
        //инициализируем класс авторизации
        authService = AuthService()
        //говорим делегату authService, что его методы будут выполняться в SceneDelegate
        authService.delegate = self
        //инициализируем свойство в котором будет связь со storyboard
        let authVC = UIStoryboard(name: "AuthViewController", bundle: nil).instantiateInitialViewController() as? AuthViewController
        //присваиваем окну - наш контроллер
        window?.rootViewController = authVC
        window?.makeKeyAndVisible()
        
    }
    
    
    //для корректного отображения URLScheme - нам необходимо добавить функцию
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        //проверяем что нам пришел верный URL
        if let url = URLContexts.first?.url {
            VKSdk.processOpen(url, fromApplication: UIApplication.OpenURLOptionsKey.sourceApplication.rawValue)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    //MARK: AuthServiceDelegate
    //когда мы подписали SceneDelegate под протокол AuthServiceDelegate - мы сказали, что методы протокола будет выполнять класс SceneDelegate
    //так как у нас в классе AuthService - реализовано так. что его методы, должен реализовывать делегат (см. AuthService)
    //получается он передает управление в данный класс, а здесь мы уже можем использовать внутренние методы и свойства (window) класса SceneDelegate
    //конечно предварительно указав делегата .delegate = self
    func authServiceShouldShow(viewController: UIViewController) {
        print(#function)
        //отобразим viewController передаваемый в функцию (передается из AuthService) (контроллер отображающий авторизацию от ВК, предоставляемую фреймворком ВК)
        window?.rootViewController?.present(viewController, animated: true, completion: nil)
    }
    
    func authServiceSignIn() {
        print(#function)
        //после того как успешно авторизовались, нам необходимо перейти обратно в наше приложения уже на наш собственный контроллер
        //кастим до нужного нам контроллера
        let feedVC = UIStoryboard(name: "NewsfeedViewController", bundle: nil).instantiateInitialViewController() as! NewsfeedViewController
        //делаем, чтобы feedViewController отображался внутри NavigationController (сверху был навигатион бар
        let navVC = UINavigationController(rootViewController: feedVC)
        //присваиваем отображаемому окну новый контроллер
        window?.rootViewController = navVC
    }
    
    func authServiceSignInDidFail() {
        print(#function)
    }


}

