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
    private var ratingLevel: Double = 8.3
    
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading

    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
           self.moviesLoader = moviesLoader
           self.delegate = delegate
       }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
            // долгая загрузка
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                // Показываем алерт об ошибке и показывавам следеющий запрос/
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailReceiveNextQuestion()
                }
                return
            }

            let rating = Double(movie.rating) ?? 0
            
            let randomRading = (75...91).randomElement() ?? 0
            self.ratingLevel = Double(randomRading)/10
            
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
        //DispatchQueue.main.async  - сетевые запросы всегда работают в другом потоке, когда мы обрабатываем ответ от загрузчика фильмов в QuestionFactory, надо тоже перейти в главный поток (используем конструкцию DispatchQueue.main.async).
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
