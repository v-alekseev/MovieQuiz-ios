//
//  FileQuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Vitaly Alekseev on 21.03.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    
    func didReceiveNextQuestion(question: QuizQuestion?)    // получили следующий вопрос
    func didFailReceiveNextQuestion()    // Ошибка получения вопроса
    
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
