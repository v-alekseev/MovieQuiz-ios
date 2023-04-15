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


    // MARK: - Private Properties
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?

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
        guard let currentQuestion = currentQuestion else { // ОШИБКА КОМПИЛЯЦИИ 1: `currentQuestion` не определён
            return
        }
        
        let givenAnswer = true
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) // ОШИБКА КОМПИЛЯЦИИ 2: метод `showAnswerResult` не определён
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    // MARK: - Private Methods


    

    

}
