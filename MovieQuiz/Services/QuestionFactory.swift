//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Vitaly Alekseev on 17.03.2023.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private var currentIndex = 0
    private var previosIndex = 0
    private let ratingLevel: Double = 8.3
    
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading

    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
           self.moviesLoader = moviesLoader
           self.delegate = delegate
       }
    
// пока это оставлено специально для ретроспективы
//    func requestNextQuestion() {
//        // это нужно что бы не повторялся два раза подряд один и тот же запрос
//        repeat{
//            guard let index = (0..<questions.count).randomElement() else {
//                delegate?.didReceiveNextQuestion(question: nil)
//                return
//            }
//            currentIndex = index
//        }while(currentIndex == previosIndex)  // Если новый индекс равен старому, запрашиваем новый
//
//        previosIndex = currentIndex
//        let question = questions[safe: currentIndex]
//        delegate?.didReceiveNextQuestion(question: question)
//        return
//    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
            // долгая загрузка
            //self.delegate?.showLoadingIndicator()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            //self.delegate?.hideLoadingIndicator()


            let rating = Double(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше чем \(self.ratingLevel)?"
            let correctAnswer = rating > self.ratingLevel

            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         rating: rating,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        // todo   зачем тут DispatchQueue.main.async
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                    self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
        }
    }
}
