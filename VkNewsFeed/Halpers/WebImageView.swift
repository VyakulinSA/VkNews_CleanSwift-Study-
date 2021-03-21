//
//  WebImageView.swift
//  VkNewsFeed
//
//  Created by Вякулин Сергей on 13.01.2021.
//

//файл для работы с изображениями из интернета
import UIKit

//создаем класс и присваиваем его элементу изображения в xib файле
class WebImageView: UIImageView {
    
    private var currentUrlString: String?
    
    //функция для обновления элемента изображения
    func set(imgeURL: String?) {
        currentUrlString = imgeURL
        //проверяем смогли ли мы получить ГКД
        guard let imgeURL = imgeURL, let url = URL(string: imgeURL) else {
            self.image = nil
            return}
        //для того, чтобы повторяющиеся изображения не загружать повторно и экономить время загрузки и трафик, будем кэшировать изображения
        
        //ВАЖНО: необходимо добавить данную проверку, для того, чтобы использовать изображения из кэша
        //опытным путем заметил, что даже без дополнительных функций для засовывания в кэш, изображения автоматически переходят в кэш
        // не понятно связано это с симулятором, или в swift так задумано на этапе получения изображения
        //типо самостоятельно в кэш складывает, и нам остается, только спросить, скачивалось ли ранее изображение
        
        //проверяем, есть ли изображение в кэше и если есть сразу присваиваем
        if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            //если изображение в кэше, то присваиваем текущему объекту(для которого запускается функция) и просто выходим (return) чтобы не идти дальше
            self.image = UIImage(data: cachedResponse.data)
            return
        }
        //работаем с ссылкой на изображение и получением изображения
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            //работать будем асинхронно, т.к. возможны большие изображения
            DispatchQueue.main.async {
                //проверяем, что смогли получить некую data и response
                if let data = data, let response = response {
                    //если впервые получаем изображение, то добавляем в кэш с помощью созданной самостоятельно функции
                    self?.handleLoadedImage(data: data, response: response)
                    
                }
            }
        }
        //задачи создаются в приостановленном режиме, поэтому для запуска надо писать resume()
        dataTask.resume()
    }
    
    
    //ВАЖНО: Если при проверке работы с изображением из кэша, мы видим, что изображения не складываются в кэш автоматически, то используем слудующую функцию
    
    //создадим функцию для проверки и записи данных о изображении в кэш
    private func handleLoadedImage(data: Data, response: URLResponse){
        //проверим можем ли вытащить URL из нашего response
        guard let responseURL = response.url else {return}
        //создадим кэшированный ответ на запрос нашего url
        let chachedResponse = CachedURLResponse(response: response, data: data)
        //обратимся к объекту который будет хранить наш кэш
        //складываем в него кэш(data) + URL по которому получено изображение и которое будем доставать из кэша
        URLCache.shared.storeCachedResponse(chachedResponse, for: URLRequest(url: responseURL))
        
        if responseURL.absoluteString == currentUrlString {
            //если картинка является текцщей в ячейке, то присваиваем ее
            self.image = UIImage(data: data)
        }
    }
}

