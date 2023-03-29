//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Vitaly Alekseev on 21.03.2023.
//

import Foundation

final class AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var  completion: (() -> Void)
    
    init(title: String,
         message: String,
         buttonText: String, completion: @escaping () -> Void ) {
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.completion = completion
    }
    
}
