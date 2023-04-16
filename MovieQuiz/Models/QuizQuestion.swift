//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Vitaly Alekseev on 17.03.2023.
//

import Foundation

// для состояния Ответ дан
struct QuizQuestion {
    let image: Data
    let text: String
    let rating: Double
    let correctAnswer: Bool
}
