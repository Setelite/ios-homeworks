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
    }

    private let loginValue = "Wowgorno"
    private let fullNameValue = "Maxim Gornostayev"
    private let statusValue = "iOS Developer"

    func getUser(login: String) -> User? {
        guard login == loginValue else { return nil }

        // Avatar priority: user-selected image from Documents -> bundled default asset.
        let avatar: UIImage
        if let fileName = UserDefaults.standard.string(forKey: Keys.avatarFileName),
           let storedAvatar = loadAvatar(named: fileName) {
            avatar = storedAvatar
        } else {
            avatar = UIImage(named: "my_photo") ?? UIImage()
        }

        return User(
            login: loginValue,
            fullName: fullNameValue,
            avatar: avatar,
            status: statusValue
        )
    }
    
    func updateAvatar(_ avatar: UIImage) {
        guard let fileName = saveAvatar(avatar) else { return }
        UserDefaults.standard.set(fileName, forKey: Keys.avatarFileName)
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
