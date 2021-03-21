//
//  AuthService.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 07.01.2021.
//


import Foundation
import VKSdkFramework

//создадим протокол для делегированния работы с контроллером от самих ВК, и прохождения на нем авторизации
protocol AuthServiceDelegate: class {
    func authServiceShouldShow(viewController: UIViewController)
    func authServiceSignIn()
    func authServiceSignInDidFail()
}



//класс необходимы для работы с авторизацией
//выносим в отдельный файл, для разделения архитекутры

class AuthService: NSObject, VKSdkDelegate, VKSdkUIDelegate {

    //добавляем свойство для хранения id нашего приложения в ВК
    private let appId = "7719964"
    //добавляем свойство для инициализации данного класса
    private let vkSdk: VKSdk
    //создаем инициализатор для инициализации свойства vkSDK
    override init() {
        vkSdk = VKSdk.initialize(withAppId: appId)
        super.init() //переопределяем родительский инициализатор (инициализатор класса NSObject)
        //чтобы мы понимали, что инициализация действительно завершилась, выведем в консоль информацию
        print("VKSdk.initialize")
        //для того, чтобы вункции делегатов заработали, мы должны сказать какой класс будет реализовывать данные функции
        vkSdk.register(self)
        vkSdk.uiDelegate = self
    }
    
    //создадим свойство экземпляра делегата
    weak var delegate: AuthServiceDelegate?
    
    //свойство для хранения уникального токена пользователя
    var token: String? {
        return VKSdk.accessToken()?.accessToken
    }
    
    //свойство для хранения user_id, чтобы получать фото пользователя
    var userId: String? {
        return VKSdk.accessToken()?.userId
    }
    
    
    //создадим функцию для проверки открытых сессий (по указанию в документации в ВК)
    func wakeUpSession() {
        //создаем массив прав доступа (см. документацию в ВК)
        let scope = ["friends","wall"]
        // вызываем метод который принимает массив прав доступа и возвращает замыкание которое хранит в себе статус в котором мы в данный момент находимся и ошибку
        VKSdk.wakeUpSession(scope) { [delegate] (state, error) in
            //[delegate] делается для того, чтобы как бы скопировать делегата внутрь замыкания, тем самым уйти от сильных ссылок на self.delegate
            switch state {
            //после ввода названия свича - можно подождать и он предложит заполнить все возможные состояния
            //нас интересует только два: initialized; authorized
            case .initialized:
                print("initialized")
                //если мы находимся в кейсе инициализации - значит у нас успешно прошла инициализация пользователя, и можно переходит к авторизации с правами доступа scope
                VKSdk.authorize(scope)
            case .authorized:
                print("authorized")
                delegate?.authServiceSignIn()
            default:
                delegate?.authServiceSignInDidFail()
            }
        }
    }
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        //для того, чтобы понимать, когда вызываются те или иные функции, поставим print #Function
        print(#function)
        //добавим проверку получения токена для работы с приложением ВК
        if result.token != nil {
            delegate?.authServiceSignIn()
        }
        
        
    }
    
    func vkSdkUserAuthorizationFailed() {
        print(#function)
        delegate?.authServiceSignInDidFail()
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        //в данной функции происходит переход на контроллер на котором отражается регистрация от самих ВК
        //мы будем производить смену контроллера через делегирование в SceneDelegate нового контроллера и отображении его на экране
        //в swift это делается через protocol
        print(#function)
        //делегируем выполнение данного метода другому классу
        delegate?.authServiceShouldShow(viewController: controller)
        //после того как мы делегировали выполнение функций, осталось сказать, кто будет выполнять данные методы
        //это мы делаем в файле SceneDelegate через .delegate = self - что означает, что класс SceneDelegate будет выполнять методы по авторизации
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print(#function)
    }
    
    
}
