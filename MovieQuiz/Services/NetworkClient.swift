//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Vitaly Alekseev on 01.04.2023.
//

import Foundation



protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

/// Отвечает за загрузку данных по URL
struct NetworkClient: NetworkRouting {

    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        // непосредственно запрос к API IMDB
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, пришла ли ошибка
            if let error = error {
                handler(Result.failure(error))
                return
            }
            
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(Result.failure(NetworkError.codeError))
                return
            }
            
            // Возвращаем данные
            guard let data = data else { return }
            handler(Result.success(data))
        }
        
        task.resume()
    }
}
