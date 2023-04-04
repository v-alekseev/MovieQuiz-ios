import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Types
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var staticService: StatisticService = StatisticServiceImplementation()
    private let moviesLoader: MoviesLoading  = MoviesLoader()

    let alertViewController = AlertPresenter()
   

    // MARK: - Constants

    // MARK: - Public Properties

    // MARK: - IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
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

    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
      // Попробуйте написать код конвертации сами
        
       // let imageData = try Data(contentsOf: someImageURL) // try, потому что загрузка данных по URL может быть и не успешной
       // let image = UIImage(data: imageData)
        
        return QuizStepViewModel(
                //image: UIImage(named: model.image) ?? UIImage(), // Загружаем картинку
            image: UIImage(data: model.image) ?? UIImage(),
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
            // Достигли последнего вопроса. показать результат квиза
            
            // сохраняем результат в  UserData
            staticService.store(correct: correctAnswers, total: questionsAmount)
            
            
            //В первой строке выводится результат текущей игры.
            //Во второй строчке выводится количество завершённых игр.
            //Третья строчка показывает информацию о лучшей попытке.
            //Четвёртая строка отображает среднюю точность правильных ответов за все игры в процентах.
            let message = """
Ваш результат: \(correctAnswers)/\(questionsAmount)
Количество сыграных квизов: \(staticService.gamesCount)
Рекорд: \(staticService.bestGame.correct)/\(staticService.bestGame.total) (\(staticService.bestGame.date.dateTimeString))
Средняя точность: \(round(staticService.totalAccuracy*100*100)/100)%
"""
    
    
            //let alertViewController = AlertPresenter(parentViewController: self)
            let alertModel = AlertModel(title: "Этот раунд окончен!",
                                   message: message,
                                   buttonText: "Сыграть ещё раз") { [weak self] in
                guard let self = self else {return}
                self.currentQuestionIndex = 0  // сразу вернем индекс в начало
                self.correctAnswers = 0 // обнулим количество правильных ответов

                self.questionFactory?.requestNextQuestion()
            }
            
            
            alertViewController.alert(model: alertModel)
          
            
        } else {
            currentQuestionIndex += 1 // увеличиваем индекс текущего урока на 1; таким образом мы сможем получить следующий урок
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func printError(_ log: String){
        print(log + " File: \(#file) function: \(#function), line: \(#line)")
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating() // выключаем анимацию
        activityIndicator.isHidden = true // говорим, что индикатор загрузки скрыт
    }
    
    private func showNetworkError(message: String) {
        //создаем и показываем алерт
        let alertModel = AlertModel(title: "Ошибка!",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else {return}

            // проверить как это работает
            // показываем индикатор загрузки
            self.showLoadingIndicator()
            self.questionFactory?.loadData()

        }
        
        alertViewController.alert(model: alertModel)
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        //скрываем индикатор загрузки
        hideLoadingIndicator()
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        //скрываем индикатор загрузки в didReceiveNextQuestion т/к/ последует долгая загрузка картинок.
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        //скрываем индикатор загрузки т.к. дальше только показ ошибки
        hideLoadingIndicator()

        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // фактически инициализируем класс показа алерта
        alertViewController.parentViewController  = self
        
        // показываем индикатор загрузки
        showLoadingIndicator()
        

        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        
        // загружаем данные
        questionFactory?.loadData()

    }
    
    // это нужно для белого шрифта в статус бар
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
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

