//
//  InfoViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 16.07.2025.
//

import UIKit

class InfoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let button = UIButton(type: .system)
        button.setTitle("Show Alert", for: .normal)
        button.addTarget(self, action: #selector(showAlert), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func showAlert() {
        let alert = UIAlertController(title: "Info", message: "This is an alert", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            print("OK tapped")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel tapped")
        })
        present(alert, animated: true)
    }
}
