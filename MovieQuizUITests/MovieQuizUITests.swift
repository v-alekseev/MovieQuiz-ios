//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Vitaly Alekseev on 11.04.2023.
//

import XCTest

class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    

    override func setUpWithError() throws {
            try super.setUpWithError()
            
            app = XCUIApplication()
            app.launch()
            
            // это специальная настройка для тестов: если один тест не прошёл,
            // то следующие тесты запускаться не будут; и правда, зачем ждать?
            continueAfterFailure = false
        }
    
    override func tearDownWithError() throws {
            try super.tearDownWithError()
            
            app.terminate()
            app = nil
        }

    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap() // находим кнопку `Да` и нажимаем её
        sleep(3)
        
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")

    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap() // находим кнопку `Да` и нажимаем её
        sleep(3)
        
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")

    }
    
    func testFinishRounAlert() {
        
        sleep(3)
        for _ in 1...10 {
            let indexLabelValue = app.staticTexts["Index"].label
            print(indexLabelValue)
            app.buttons["No"].tap() // находим кнопку `Да` и нажимаем её
            sleep(2)
        }
        
        let finAlert = app.alerts["finishAlert"]
        print(finAlert.label)
        print(finAlert.buttons.firstMatch.label)
    
        XCTAssertTrue(finAlert.exists)
        XCTAssertEqual(finAlert.label, "Этот раунд окончен!")
        XCTAssertEqual(finAlert.buttons.firstMatch.label, "Сыграть ещё раз")

    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
