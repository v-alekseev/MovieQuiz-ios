//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Vitaly Alekseev on 21.03.2023.
//

import UIKit

class AlertPresenter {
    weak var parentViewController: UIViewController? = nil
    

    func alert(model: AlertModel){
        
        // создаём объекты всплывающего окна
        let alert = UIAlertController(title:  model.title, // заголовок всплывающего окна
                                      message: model.message, // текст во всплывающем окне
                                      preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet

        alert.view.accessibilityIdentifier = "finishAlert"

        // создаём для него кнопки с действиями( нажали "Сыграть ещё раз")
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }

        // добавляем в алерт кнопки
        alert.addAction(action)

        // показываем всплывающее окно
        guard let parentViewController = parentViewController else {return}
        
        parentViewController.present(alert, animated: true, completion: nil)
    }
    
}
