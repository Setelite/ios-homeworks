//
//  CustomButton.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/23/25.
//

import UIKit

final class CustomButton: UIButton {

    private var action: (() -> Void)?

    init(title: String,
         titleColor: UIColor = StyleGuide.Colors.inverseText,
         backgroundColor: UIColor = StyleGuide.Colors.accent,
         cornerRadius: CGFloat = 12,
         action: (() -> Void)? = nil) {

        super.init(frame: .zero)

        self.action = action

        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = StyleGuide.Fonts.body(15, weight: .semibold)
        self.backgroundColor = backgroundColor
        layer.cornerRadius = cornerRadius

        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonTapped() {
        action?()
    }
}
