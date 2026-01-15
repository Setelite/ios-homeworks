//
//  SettingsViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/13/26.
//

import UIKit

final class SettingsViewController: UITableViewController {

    // MARK: - Callbacks (для Coordinator)
    var onChangePassword: (() -> Void)?
    var onLogout: (() -> Void)?

    // MARK: - Sections
    enum Section: Int, CaseIterable {
        case sorting
        case security
        case account
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройки"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - Table DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        1
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        switch Section(rawValue: indexPath.section)! {

        case .sorting:
            cell.textLabel?.text = "Сортировка A–Z"

            let toggle = UISwitch()
            toggle.isOn = SettingsStorage.shared.isAscending
            toggle.addTarget(self, action: #selector(sortChanged(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.selectionStyle = .none

        case .security:
            cell.textLabel?.text = "Поменять пароль"
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = nil
            cell.selectionStyle = .default

        case .account:
            cell.textLabel?.text = "Выйти из аккаунта"
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.textAlignment = .center
            cell.accessoryView = nil
            cell.selectionStyle = .default
        }

        return cell
    }

    // MARK: - Table Delegate
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch Section(rawValue: indexPath.section)! {

        case .sorting:
            break

        case .security:
            onChangePassword?()

        case .account:
            onLogout?()
        }
    }

    // MARK: - Actions
    @objc private func sortChanged(_ sender: UISwitch) {
        SettingsStorage.shared.isAscending = sender.isOn
    }
}
