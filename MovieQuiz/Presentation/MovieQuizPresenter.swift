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
    

    // MARK: - Private Methods

    private func didAnswer(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    

    

}
