//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Vitaly Alekseev on 25.03.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isWorse(then: GameRecord) -> Bool{
        return (self.correct < then.correct)
    }
}

protocol StatisticService {
    var totalAccuracy: Double { get } // среднюю точность правильных ответов за все игры в процентах. Средняя точность, рассчитывающаяся как отношение правильно отвеченных вопросов за всё время игры к общему количеству вопросов за всё время игры. Точность должна быть выражена в процентах.
    var gamesCount: Int { get } //количество завершённых игр.
    var bestGame: GameRecord { get } // информацию о лучшей попытке.
   // var totalCorrectAnswer : Int { get } // правильно отвеченных вопросов за всё время игры
    
    func store(correct count: Int, total amount: Int)  //  сохранение текущег результата
}

//В первой строке выводится результат текущей игры.
//Во второй строчке выводится количество завершённых игр.
//Третья строчка показывает информацию о лучшей попытке.
//Четвёртая строка отображает среднюю точность правильных ответов за все игры в процентах.


final class StatisticServiceImplementation: StatisticService {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount, totalCorrectAnswers
    }
    
    private let userDefaults = UserDefaults.standard
    
    private var totalCorrectAnswer: Int {
        get {
            return userDefaults.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    var totalAccuracy: Double {
        get {
            return userDefaults.double(forKey: Keys.total.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
        var gamesCount: Int {
            get {
                return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
            }
            
            set {
                userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
            }
        }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    

    
    func store(correct count: Int, total amount: Int) {
        let currentGameResult = GameRecord(correct: count, total: amount, date: Date.init())
        
        self.gamesCount += 1
        
        if self.bestGame.isWorse(then: currentGameResult) {
            self.bestGame = currentGameResult
        }
        
        self.totalCorrectAnswer += count
        self.totalAccuracy = Double(self.totalCorrectAnswer)/Double((amount * self.gamesCount))
    }
    
    // служебная функция для теста. Оставим пока тут
    func clear() {
        
        self.totalAccuracy = 0
        self.gamesCount = 0
        self.bestGame = GameRecord(correct: 0, total: 0, date: Date())
        self.totalCorrectAnswer = 0

        
    }

    
}
//Comparable
