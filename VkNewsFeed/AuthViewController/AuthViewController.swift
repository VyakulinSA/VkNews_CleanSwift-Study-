//
//  ViewController.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 06.01.2021.
//

import UIKit


//для того, чтобы при запуске приложения, у нас не открывался первый экран, а сразу шло на регистрацию через VK
//удаляем Main.storyboard
//в General настройках приложения - стираем название начального экрана
//в info.plist - Application Scene Manifest - Scene Configuration - Application Session Role - удаляем строку Storyboard Name
//переименовываем текущий контроллер
//создаем к нему свой собственный storyboard
//проводим настройки в данном классе
class AuthViewController: UIViewController {
    
    //создаем свойство для инициализации экземпляра класса AuthService
    private var authService: AuthService!

    override func viewDidLoad() {
        super.viewDidLoad()
        //инициализируем authService общим (singleTone) объектом
        authService = SceneDelegate.shared().authService
        //добавим изменение заливки у экрана приложения
        view.backgroundColor = .red
    }

    @IBAction func signInTouch(_ sender: UIButton) {
        //при нажатии на кнопку, вызываем функцию проверки активной сессии
        authService.wakeUpSession()
    }
    
}

