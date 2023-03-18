import UIKit


final class MovieQuizViewController: UIViewController {
    // MARK: - Types
    private let questionsAmount: Int = 10
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    // MARK: - Constants

    // MARK: - Public Properties

    // MARK: - IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    // MARK: - Private Properties
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0

    // MARK: - Initializers

    // MARK: - UIViewController(*)

    // MARK: - Public methods

    // MARK: - IBAction


    @IBAction private func yesButtonClicked(_ sender: UIButton) {
    
        let givenAnsver = true
        
        // // проверяем что индекс не выходит за пределы массива
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        // определяем правильный или нет ответ и показываем его
        showAnswerResult(isCorrect: currentQuestion.correctAnswer  == givenAnsver)
        
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        let givenAnsver = false
        
        // проверяем что данный ответ совпадает с правильным correctAnswer
        // // проверяем что индекс не выходит за пределы массива
        guard let currentQuestion = currentQuestion else {
            return
        }
        // определяем правильный или нет ответ и показываем его
        showAnswerResult(isCorrect: currentQuestion.correctAnswer  == givenAnsver)

    }
    
    
    // MARK: - Private Methods
    private func show(quiz step: QuizStepViewModel) {
      // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        
    }

    private func show(quiz result: QuizResultsViewModel) {
      // здесь мы показываем результат прохождения квиза
        
        // создаём объекты всплывающего окна
        let alert = UIAlertController(title:  result.title, // заголовок всплывающего окна
                                      message: result.text, // текст во всплывающем окне
                                      preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet

        // создаём для него кнопки с действиями( нажали "Сыграть ещё раз")
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else {return}
            self.currentQuestionIndex = 0  // сразу вернем индекс в начало
            self.correctAnswers = 0 // обнулим количество правильных ответов
            
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                
                self.show(quiz: viewModel)
            }
        }

        // добавляем в алерт кнопки
        alert.addAction(action)

        // показываем всплывающее окно
        self.present(alert, animated: true, completion: nil)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
      // Попробуйте написать код конвертации сами
        return QuizStepViewModel(
                image: UIImage(named: model.image) ?? UIImage(), // Загружаем картинку
                question: model.text,  // тупо тект
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") // высчитываем номер вопроса

      }

    
    private func showAnswerResult(isCorrect: Bool) {
        
        // блокируем кнопки
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor  // цвет рамки
        
        if isCorrect { correctAnswers += 1} // если ответ правильный, увеличим счетчик
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {  [weak self] in // запускаем задачу через 1 секунду
            guard let self = self else {return}
            // код, который вы хотите вызвать через 1 секунду,
            // включаем кноаки
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            self.showNextQuestionOrResults()
        }

    }
    
    private func showNextQuestionOrResults() {
        
        if currentQuestionIndex == questionsAmount - 1 { // - 1 потому что индекс начинается с 0, а длинна массива — с 1
            // показать результат квиза
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                buttonText: "Сыграть ещё раз")
            show(quiz: result)
          
            
        } else {
            currentQuestionIndex += 1 // увеличиваем индекс текущего урока на 1; таким образом мы сможем получить следующий урок
            if let nextQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = nextQuestion
                let viewModel = self.convert(model: nextQuestion)
                
                self.show(quiz: viewModel)
            }
        }
    }
    
    private func printError(_ log: String){
        print(log + " File: \(#file) function: \(#function), line: \(#line)")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
     
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
