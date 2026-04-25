//
//  SettingsViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/13/26.
//

import UIKit

extension Notification.Name {
    static let appDidRequestLogout = Notification.Name("appDidRequestLogout")
}

final class SettingsViewController: UITableViewController {

    // MARK: - Callbacks (для Coordinator)
    var onChangePassword: (() -> Void)?
    var onLogout: (() -> Void)?

    // MARK: - Sections
    enum Section: Int, CaseIterable {
        case appearance
        case sorting
        case security
        case account
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("settings.title")
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
        cell.accessoryType = .none
        cell.accessoryView = nil
        cell.selectionStyle = .default
        cell.textLabel?.textAlignment = .natural
        cell.textLabel?.textColor = StyleGuide.Colors.textPrimary

        switch Section(rawValue: indexPath.section)! {
        case .appearance:
            cell.textLabel?.text = L10n.tr("settings.theme")

            let segmented = UISegmentedControl(items: [
                L10n.tr("theme.system"),
                L10n.tr("theme.light"),
                L10n.tr("theme.dark")
            ])
            segmented.selectedSegmentIndex = SettingsStorage.shared.themeMode.rawValue
            segmented.addTarget(self, action: #selector(themeChanged(_:)), for: .valueChanged)
            cell.accessoryView = segmented
            cell.selectionStyle = .none
            cell.textLabel?.textAlignment = .natural
            cell.textLabel?.textColor = StyleGuide.Colors.textPrimary

        case .sorting:
            cell.textLabel?.text = L10n.tr("settings.sort")

            let toggle = UISwitch()
            toggle.isOn = SettingsStorage.shared.isAscending
            toggle.addTarget(self, action: #selector(sortChanged(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.selectionStyle = .none

        case .security:
            cell.textLabel?.text = L10n.tr("settings.change_password")
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default

        case .account:
            cell.textLabel?.text = L10n.tr("settings.logout")
            cell.textLabel?.textColor = StyleGuide.Colors.danger
            cell.textLabel?.textAlignment = .center
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
        case .appearance:
            break

        case .sorting:
            break

        case .security:
            onChangePassword?()

        case .account:
            presentLogoutConfirmation()
        }
    }

    // MARK: - Actions
    @objc private func sortChanged(_ sender: UISwitch) {
        SettingsStorage.shared.isAscending = sender.isOn
    }

    @objc private func themeChanged(_ sender: UISegmentedControl) {
        guard let mode = AppThemeMode(rawValue: sender.selectedSegmentIndex) else { return }
        SettingsStorage.shared.themeMode = mode
    }

    private func presentLogoutConfirmation() {
        let alert = UIAlertController(
            title: L10n.tr("settings.logout"),
            message: L10n.tr("settings.logout.confirm_message"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.tr("common.cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.tr("settings.logout"), style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        present(alert, animated: true)
    }

    private func performLogout() {
        FirebaseSessionStorage.shared.clear()
        if let onLogout {
            onLogout()
        } else {
            NotificationCenter.default.post(name: .appDidRequestLogout, object: nil)
        }
    }
}
