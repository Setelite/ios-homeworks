//
//  ViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 16.07.2025.
//

import UIKit

final class ViewController: UIViewController {

    private let tableView = UITableView()
    private var items: [URL] = []

    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("documents.title")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary

        setupTableView()
        loadFiles()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addPhotoTapped)
        )
    }
}

// MARK: - Setup
private extension ViewController {

    func setupTableView() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
    }

    func loadFiles() {
        do {
            items = try FileManager.default.contentsOfDirectory(
                at: documentsURL,
                includingPropertiesForKeys: nil
            )
            tableView.reloadData()
        } catch {
            let errorTitle = L10n.tr("documents.error.load")
            print("\(errorTitle): \(error)")
        }
    }
}

// MARK: - Actions
private extension ViewController {

    @objc func addPhotoTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let fileURL = items[indexPath.row]

        cell.textLabel?.text = fileURL.lastPathComponent
        cell.imageView?.image = UIImage(contentsOfFile: fileURL.path)

        return cell
    }

    //Свайп для удаления
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: L10n.tr("common.delete")) { [weak self] _, _, completion in
            guard let self = self else { return }

            let fileURL = self.items[indexPath.row]

            do {
                try FileManager.default.removeItem(at: fileURL)
                self.items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completion(true)
            } catch {
                let errorTitle = L10n.tr("documents.error.delete")
                print("\(errorTitle): \(error)")
                completion(false)
            }
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Image Picker
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }

        let fileName = UUID().uuidString + ".jpg"
        let fileURL = documentsURL.appendingPathComponent(fileName)

        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: fileURL)
            loadFiles()
        }
    }
}
