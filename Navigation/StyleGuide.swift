import UIKit

enum StyleGuide {
    enum Colors {
        // Адаптация темная/светлая тема
        static let vkBlue = UIColor(red: 0.16, green: 0.47, blue: 0.91, alpha: 1.0)
        static let backgroundPrimary = UIColor.systemBackground
        static let backgroundSecondary = UIColor.secondarySystemBackground
        static let textPrimary = UIColor.label
        static let textSecondary = UIColor.secondaryLabel
        static let accent = vkBlue
        static let border = UIColor.separator
        static let borderStrong = UIColor.systemGray3
        static let danger = UIColor.systemRed
        static let success = UIColor.systemGreen
        static let muted = UIColor.systemGray
        static let inverseText = UIColor.white
        static let card = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.tertiarySystemBackground
                : UIColor.white
        }
    }

    enum Fonts {
        static func title(_ size: CGFloat = 24, weight: UIFont.Weight = .bold) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: weight)
        }

        static func body(_ size: CGFloat = 16, weight: UIFont.Weight = .regular) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: weight)
        }

        static func caption(_ size: CGFloat = 13, weight: UIFont.Weight = .medium) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
}
