//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Vitaly Alekseev on 17.03.2023.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    var currentIndex = 0
    var previosIndex = 0
    
    weak var delegate: QuestionFactoryDelegate?

    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", rating: 9.2, correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", rating: 9, correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", rating: 8.1, correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", rating: 8, correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", rating: 8, correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", rating: 6.6, correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", rating: 5.8, correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", rating: 4.3, correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", rating: 5.1, correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", rating: 5.8, correctAnswer: false)
    ]
    
    init(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        // это нужно что бы не повторялся два раза подряд один и тот же запрос
        repeat{
            guard let index = (0..<questions.count).randomElement() else {
                delegate?.didReceiveNextQuestion(question: nil)
                return
            }
            currentIndex = index
        }while(currentIndex == previosIndex)  // Если новый индекс равен старому, запрашиваем новый
          
        previosIndex = currentIndex
        let question = questions[safe: currentIndex]
        delegate?.didReceiveNextQuestion(question: question)
        return
    } 
}
