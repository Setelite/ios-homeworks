//
//  PostViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 16.07.2025.
//

import UIKit

class PostViewController: UIViewController {
    var post: Post?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange
        title = post?.title

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(showInfo))
    }

    @objc func showInfo() {
        let infoVC = InfoViewController()
        infoVC.modalPresentationStyle = .formSheet
        present(infoVC, animated: true)
    }
}
