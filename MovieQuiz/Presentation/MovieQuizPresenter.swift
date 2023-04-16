//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Vitaly Alekseev on 15.04.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    
    
    // MARK: - Types

    // MARK: - Constants
    let questionsAmount: Int = 10

    // MARK: - Public Properties
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?

    // MARK: - Private Properties
    private var currentQuestionIndex: Int = 0
    private var staticService: StatisticService = StatisticServiceImplementation()

    // MARK: - Initializers

    // MARK: - Public methods
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,  // тупо тект
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") // высчитываем номер вопроса
      }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
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
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = self.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
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
                self.resetQuestionIndex() //currentQuestionIndex = 0  // сразу вернем индекс в начало
                self.correctAnswers = 0 // обнулим количество правильных ответов

                self.questionFactory?.requestNextQuestion()
            }
            
            
            self.viewController?.alertViewController.alert(model: alertModel)
          
            
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
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    

    

}
