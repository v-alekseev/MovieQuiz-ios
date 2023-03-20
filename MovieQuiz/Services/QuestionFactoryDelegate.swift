//
//  FileQuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Vitaly Alekseev on 21.03.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
