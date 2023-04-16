//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Vitaly Alekseev on 15.04.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    
    // MARK: - Types

    // MARK: - Constants
    let questionsAmount: Int = 10

    // MARK: - Public Properties
    var currentQuestion: QuizQuestion?
   // weak var viewController: MovieQuizViewController?
    weak var viewController: MovieQuizViewControllerProtocol?
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?

    // MARK: - Private Properties
    private var currentQuestionIndex: Int = 0
    private var staticService: StatisticService = StatisticServiceImplementation()

    // MARK: - Initializers
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
//    init(viewController: MovieQuizViewControllerProtocol) {
//        // пустой конструктор для поддерки тестов
//    }

    // MARK: - QuestionFactoryDelegate methods
    
    func didLoadDataFromServer() {
        //скрываем индикатор загрузки в didReceiveNextQuestion т/к/ последует долгая загрузка картинок.
        questionFactory?.requestNextQuestion()
    }
    
    
    func didFailToLoadData(with error: Error) {
        //скрываем индикатор загрузки т.к. дальше только показ ошибки
        viewController?.hideLoadingIndicator()

        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    func didFailReceiveNextQuestion() {

        let alertModel = AlertModel(title: "Ошибка загрузки вопроса!",
                               message: "К сожалению, не получилось загрузить вопрос.",
                               buttonText: "Загрузить следующий вопрос") { [weak self] in
            guard let self = self else {return}
            
            self.questionFactory?.requestNextQuestion()
        }
        // todo Подумать что бы пееренести alertViewController в презентер
        viewController?.getAlertPresenter().alert(model: alertModel)
    }
    

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        //скрываем индикатор загрузки
        viewController?.hideLoadingIndicator()

        currentQuestion = question
        let viewModel = self.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    // MARK: - Public methods
    
    func showAnswerResult(isCorrect: Bool) {
        
        // блокируем кнопки
        viewController?.enableButtons(false)
        
        viewController?.highlightImageBorder(isCorrect: isCorrect)
     
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {  [weak self] in // запускаем задачу через 1 секунду
            // код, который вы хотите вызвать через 1 секунду,
            guard let self = self else {return}
            // включаем кноаки
            self.viewController?.enableButtons(true)

            self.showNextQuestionOrResults()
        }

    }
    
    func showNetworkError(message: String) {
        //создаем и показываем алерт
        let alertModel = AlertModel(title: "Ошибка!",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else {return}

            // проверить как это работает
            // показываем индикатор загрузки
            self.viewController?.showLoadingIndicator()
            // пытаемся опять загрузить данные
            self.questionFactory?.loadData()

        }
        
        viewController?.getAlertPresenter().alert(model: alertModel)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,  // тупо тект
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") // высчитываем номер вопроса
      }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        didAnswer(givenAnswer: true)
    }
    
    func noButtonClicked() {
        didAnswer(givenAnswer: false)
    }
    
    
    func showNextQuestionOrResults() {
        
        if self.isLastQuestion() {
            // Достигли последнего вопроса. показать результат квиза
            
            // сохраняем результат в  UserData
            staticService.store(correct: correctAnswers, total: self.questionsAmount)
            
            
            //В первой строке выводится результат текущей игры.
            //Во второй строчке выводится количество завершённых игр.
            //Третья строчка показывает информацию о лучшей попытке.
            //Четвёртая строка отображает среднюю точность правильных ответов за все игры в процентах.
            let message = """
Ваш результат: \(correctAnswers)/\(self.questionsAmount)
Количество сыграных квизов: \(staticService.gamesCount)
Рекорд: \(staticService.bestGame.correct)/\(staticService.bestGame.total) (\(staticService.bestGame.date.dateTimeString))
Средняя точность: \(round(staticService.totalAccuracy*100*100)/100)%
"""
    
    

            let alertModel = AlertModel(title: "Этот раунд окончен!",
                                   message: message,
                                   buttonText: "Сыграть ещё раз") { [weak self] in
                guard let self = self else {return}
                
                self.restartGame() // self.questionFactory?.requestNextQuestion()  делаем внутри
            }
            
            self.viewController?.getAlertPresenter().alert(model: alertModel)
          
            
        } else {
            // Показываем следующий вопрос
            self.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }

    // MARK: - Private Methods

    private func didAnswer(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = (givenAnswer == currentQuestion.correctAnswer)
        
        if isCorrect { self.correctAnswers += 1} // если ответ правильный, увеличим счетчик
        
        showAnswerResult(isCorrect: isCorrect) // показываем рамку соответствующего цвета и слудующий вопрос
    }
    
    private func restartGame() {
        currentQuestionIndex = 0 // вернем инекс вопроса в начало
        correctAnswers = 0 // обнулим количество правильных ответов
        questionFactory?.requestNextQuestion() // запросим следующий вопрос
    }
    

}
