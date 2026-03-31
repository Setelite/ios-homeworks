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
    private let viewModel = FeedViewModel()

    // MARK: - UI

    private let guessField: UITextField = {
        let field = UITextField()
        field.placeholder = L10n.tr("feed.enter_word")
        field.backgroundColor = StyleGuide.Colors.backgroundSecondary
        field.layer.borderColor = StyleGuide.Colors.borderStrong.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 10
        field.setLeftPaddingPoints(10)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var checkGuessButton = CustomButton(
        title: L10n.tr("feed.check"),
        backgroundColor: StyleGuide.Colors.accent
    ) { [weak self] in
        self?.checkWord()
    }

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = StyleGuide.Fonts.body(18, weight: .medium)
        label.textAlignment = .center
        label.textColor = StyleGuide.Colors.textPrimary
        label.text = L10n.tr("feed.enter_word")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.tr("feed.title")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary

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
        viewModel.check(word: guessField.text)

        switch viewModel.state {
        case .idle:
            resultLabel.text = L10n.tr("feed.enter_word")
            resultLabel.textColor = StyleGuide.Colors.textPrimary
        case .emptyInput:
            resultLabel.text = L10n.tr("feed.enter_word_required")
            resultLabel.textColor = StyleGuide.Colors.danger
        case .checked(let isCorrect):
            if isCorrect {
                resultLabel.text = L10n.tr("feed.correct")
                resultLabel.textColor = StyleGuide.Colors.success
            } else {
                resultLabel.text = L10n.tr("feed.incorrect")
                resultLabel.textColor = StyleGuide.Colors.danger
            }
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
