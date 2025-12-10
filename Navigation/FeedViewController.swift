//
//  FeedViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 16.07.2025.
//

import UIKit

final class FeedViewController: UIViewController {

    
    var onOpenPost: ((Post) -> Void)?

    // MARK: - Model
    private let model = FeedModel()

    // MARK: - UI

    private let guessField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите слово"
        field.backgroundColor = .systemGray6
        field.layer.borderColor = UIColor.systemGray3.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 10
        field.setLeftPaddingPoints(10)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var checkGuessButton = CustomButton(
        title: "Проверить",
        backgroundColor: .systemBlue
    ) { [weak self] in
        self?.checkWord()
    }

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "Введите слово"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Feed"
        view.backgroundColor = .white

        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(guessField)
        view.addSubview(checkGuessButton)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            guessField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            guessField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            guessField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            guessField.heightAnchor.constraint(equalToConstant: 50),

            checkGuessButton.topAnchor.constraint(equalTo: guessField.bottomAnchor, constant: 16),
            checkGuessButton.leadingAnchor.constraint(equalTo: guessField.leadingAnchor),
            checkGuessButton.trailingAnchor.constraint(equalTo: guessField.trailingAnchor),
            checkGuessButton.heightAnchor.constraint(equalToConstant: 50),

            resultLabel.topAnchor.constraint(equalTo: checkGuessButton.bottomAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: guessField.leadingAnchor),
            resultLabel.trailingAnchor.constraint(equalTo: guessField.trailingAnchor),
            resultLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    // MARK: - Logic
    private func checkWord() {
        guard let word = guessField.text,
              !word.isEmpty else {
            resultLabel.text = "Введите слово!"
            resultLabel.textColor = .red
            return
        }

        let isCorrect = model.check(word: word)

        if isCorrect {
            resultLabel.text = "Верно!"
            resultLabel.textColor = .systemGreen
        } else {
            resultLabel.text = "Неверно!"
            resultLabel.textColor = .systemRed
        }
    }
}

// MARK: - Padding Helper
private extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
}
