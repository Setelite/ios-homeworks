//
//  FeedViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 16.07.2025.
//

import UIKit

final class FeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        let post1 = Post(title: "Hello from Button 1")
        let post2 = Post(title: "Hello from Button 2")

        let button1 = makeButton(with: "Open Post 1")
        let button2 = makeButton(with: "Open Post 2")

        button1.addAction(UIAction { [weak self] _ in
            let vc = PostViewController()
            vc.post = post1
            self?.navigationController?.pushViewController(vc, animated: true)
        }, for: .touchUpInside)

        button2.addAction(UIAction { [weak self] _ in
            let vc = PostViewController()
            vc.post = post2
            self?.navigationController?.pushViewController(vc, animated: true)
        }, for: .touchUpInside)

        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
    }

    private func makeButton(with title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
}
