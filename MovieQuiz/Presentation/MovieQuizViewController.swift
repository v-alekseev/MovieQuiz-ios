import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Types
    //private let questionsAmount: Int = 10
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion? // todo delete
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
    //private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0

    // MARK: - Initializers

    // MARK: - UIViewController(*)

    // MARK: - Public methods
    
    func showAnswerResult(isCorrect: Bool) {
        
        // блокируем кнопки
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        // устанавливаем цвет рамки в зависимости от того, правильный или нет ответ
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

    // MARK: - IBAction
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    
    // MARK: - Private Methods
    private func show(quiz step: QuizStepViewModel) {

        imageView.backgroundColor = UIColor.ypBlack
        
        // меняем цвет рамки на черный, т/к/ новый вопрос
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        
        // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        
        if presenter.isLastQuestion() { // - 1 потому что индекс начинается с 0, а длинна массива — с 1
            // Достигли последнего вопроса. показать результат квиза
            
            // сохраняем результат в  UserData
            staticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            
            //В первой строке выводится результат текущей игры.
            //Во второй строчке выводится количество завершённых игр.
            //Третья строчка показывает информацию о лучшей попытке.
            //Четвёртая строка отображает среднюю точность правильных ответов за все игры в процентах.
            let message = """
Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
Количество сыграных квизов: \(staticService.gamesCount)
Рекорд: \(staticService.bestGame.correct)/\(staticService.bestGame.total) (\(staticService.bestGame.date.dateTimeString))
Средняя точность: \(round(staticService.totalAccuracy*100*100)/100)%
"""
    
    

            let alertModel = AlertModel(title: "Этот раунд окончен!",
                                   message: message,
                                   buttonText: "Сыграть ещё раз") { [weak self] in
                guard let self = self else {return}
                self.presenter.resetQuestionIndex() //currentQuestionIndex = 0  // сразу вернем индекс в начало
                self.correctAnswers = 0 // обнулим количество правильных ответов

                self.questionFactory?.requestNextQuestion()
            }
            
            
            alertViewController.alert(model: alertModel)
          
            
        } else {
            presenter.switchToNextQuestion() //currentQuestionIndex += 1 // увеличиваем индекс текущего урока на 1; таким образом мы сможем получить следующий урок
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func printError(_ log: String){
        print(log + " File: \(#file) function: \(#function), line: \(#line)")
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating() // выключаем анимацию
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
    func didFailReceiveNextQuestion() {

        let alertModel = AlertModel(title: "Ошибка загрузки вопроса!",
                               message: "К сожалению, не получилось загрузить вопрос.",
                               buttonText: "Загрузить следующий вопрос") { [weak self] in
            guard let self = self else {return}
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertViewController.alert(model: alertModel)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        //скрываем индикатор загрузки
        hideLoadingIndicator()
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
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
        alertViewController.parentViewController  = self
        
        // рисуем рамку вокруг картинки
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        
        imageView.backgroundColor = UIColor.ypWhite
        
        presenter.viewController = self
        
        // показываем индикатор загрузки
        activityIndicator.hidesWhenStopped = true

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

