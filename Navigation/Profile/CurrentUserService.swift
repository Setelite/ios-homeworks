//
//  CurrentUserService.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/11/25.
//

import Foundation
import StorageService
import UIKit

/// Provides current logged-in user profile data and persists selected avatar locally.
final class CurrentUserService: UserService {
    private enum Keys {
        static let avatarFileName = "currentUser.avatarFileName"
        static let fullName = "currentUser.fullName"
        static let status = "currentUser.status"
    }

    private let defaultLoginValue = "Wowgorno"
    private let defaultFullNameValue = "Maxim Gornostayev"
    private let defaultStatusValue = "iOS Developer"

    func getUser(login: String) -> User? {
        let sessionUser = FirebaseSessionStorage.shared.user
        let targetLogin = sessionUser?.email ?? defaultLoginValue
        guard login == targetLogin || login == defaultLoginValue else { return nil }

        // Avatar priority: user-selected image from Documents -> bundled default asset.
        let avatar: UIImage
        if let fileName = UserDefaults.standard.string(forKey: Keys.avatarFileName),
           let storedAvatar = loadAvatar(named: fileName) {
            avatar = storedAvatar
        } else {
            avatar = UIImage(named: "my_photo") ?? UIImage()
        }

        let fullName: String = {
            if let cached = UserDefaults.standard.string(forKey: Keys.fullName), !cached.isEmpty {
                return cached
            }
            if let sessionName = sessionUser?.displayName, !sessionName.isEmpty {
                return sessionName
            }
            return defaultFullNameValue
        }()

        let status: String = {
            if let cached = UserDefaults.standard.string(forKey: Keys.status), !cached.isEmpty {
                return cached
            }
            if sessionUser != nil {
                return L10n.tr("profile.status.firebase")
            }
            return defaultStatusValue
        }()

        return User(
            login: targetLogin,
            fullName: fullName,
            avatar: avatar,
            status: status
        )
    }
    
    func updateAvatar(_ avatar: UIImage) {
        guard let fileName = saveAvatar(avatar) else { return }
        UserDefaults.standard.set(fileName, forKey: Keys.avatarFileName)
    }

    func updateProfile(fullName: String, status: String) {
        UserDefaults.standard.set(fullName, forKey: Keys.fullName)
        UserDefaults.standard.set(status, forKey: Keys.status)
    }
    
    private func documentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    private func saveAvatar(_ avatar: UIImage) -> String? {
        guard let directory = documentsDirectory(),
              let data = avatar.jpegData(compressionQuality: 0.9) else { return nil }
        let fileName = "current_avatar.jpg"
        let fileURL = directory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL, options: .atomic)
            return fileName
        } catch {
            return nil
        }
    }
    
    private func loadAvatar(named fileName: String) -> UIImage? {
        guard let directory = documentsDirectory() else { return nil }
        let fileURL = directory.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
}
