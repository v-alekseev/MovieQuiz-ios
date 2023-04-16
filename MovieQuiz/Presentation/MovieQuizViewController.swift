import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    
    func highlightImageBorder(isCorrect: Bool)
    
    func enableButtons(_ isEnabled: Bool) 
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func getAlertPresenter() -> AlertPresenter 
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {

    // MARK: - Constants

    // MARK: - Public Properties

    private let alertViewController = AlertPresenter()
   
    // MARK: - IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    // MARK: - Private Properties

    private var presenter: MovieQuizPresenter!

    // MARK: - Initializers

    // MARK: - Public methods
    
    func getAlertPresenter() -> AlertPresenter {
        return alertViewController
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    func enableButtons(_ isEnabled: Bool) {
        // isEnabled == false - кнопки блокированы
        // isEnabled == true - кнопки активны
        
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        // устанавливаем цвет рамки в зависимости от того, правильный или нет ответ
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor  // цвет рамки
    }
    
    // MARK: - IBAction
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {

        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {

        presenter.yesButtonClicked()
    }
    
    
    // MARK: - Private Methods
    func show(quiz step: QuizStepViewModel) {

        imageView.backgroundColor = UIColor.ypBlack
        
        // меняем цвет рамки на черный, т/к/ новый вопрос
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        
        // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    

    
    private func printError(_ log: String){
        print(log + " File: \(#file) function: \(#function), line: \(#line)")
    }
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertViewController.parentViewController  = self
        
        // показываем индикатор загрузки
        activityIndicator.hidesWhenStopped = true
        
        // рисуем рамку вокруг картинки
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        
        imageView.backgroundColor = UIColor.ypWhite
        
        // Создаем presentor
        presenter = MovieQuizPresenter(viewController: self)
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

