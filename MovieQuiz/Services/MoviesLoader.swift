//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Vitaly Alekseev on 02.04.2023.
//

import Foundation


protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}


struct MoviesLoader: MoviesLoading {
    
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_b3oo3uuv") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                    do {
                        // преобразуем полученный json из API к типу MostPopularMovies
                        let movies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                        print(movies.items.count)
                        
                        handler(Result.success(movies))
                        
                    } catch {
                        print("Failed to parse: \(error.localizedDescription)")
                        handler(Result.failure(error))
                    }
            case .failure(let error):
                handler(Result.failure(error))
                }
        }
    }
}
