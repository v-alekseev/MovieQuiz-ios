import UIKit

final class MovieQuizViewController: UIViewController {
    
  
    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        Тут имеет смысл наполнить наше view данными.
        */
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      /*
      Тут имеет смысл дополнительно настроить наши изображения, например,
      задать цвет фона для экрана.
      */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
        Тут имеет смысл оповестить систему аналитики о том, что экран показался.
        */
      }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      /*
      Тут имеет смысл остановить все процессы, которые происходили на этом экране.
      */
    }
    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      /*
      Тут имеет смысл оповестить систему аналитики, что экран перестал показываться
      и привести его в изначальное состояние.
      */
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
