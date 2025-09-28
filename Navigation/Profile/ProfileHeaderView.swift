//
//  ProfileHeaderView.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 22.07.2025.
//

import StorageService
import UIKit

class ProfileHeaderView: UIView {
    
    // UI элементы
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let statusLabel = UILabel()
    private let statusTextField = UITextField()
    private let setStatusButton = UIButton(type: .system)
    
    // Приватное хранилище текста
    private var statusText: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGray6
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .systemGray6
        
        // Аватар
        avatarImageView.image = UIImage(named: "avatar")
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 50        // половина от width/height
        avatarImageView.layer.borderWidth = 3
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Имя
        nameLabel.text = "Максим Горноставев"
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Статус
        statusLabel.text = "Текущий статус"
        statusLabel.font = .systemFont(ofSize: 14, weight: .regular)
        statusLabel.textColor = .gray
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Текстовое поле
        statusTextField.placeholder = "Введите новый статус"
        statusTextField.font = .systemFont(ofSize: 14)
        statusTextField.textColor = .black
        statusTextField.borderStyle = .none
        statusTextField.layer.masksToBounds = true
        statusTextField.layer.cornerRadius = 12
        statusTextField.layer.borderWidth = 1
        statusTextField.layer.borderColor = UIColor.black.cgColor
        statusTextField.backgroundColor = .white
        statusTextField.clearButtonMode = .whileEditing
        statusTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем обработчик изменения текста
        statusTextField.addTarget(self, action: #selector(statusTextChanged(_:)), for: .editingChanged)
        statusTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        statusTextField.leftViewMode = .always
        
        // Кнопка
        setStatusButton.setTitle("Показать статус", for: .normal)
        setStatusButton.backgroundColor = .systemBlue
        setStatusButton.setTitleColor(.white, for: .normal)
        setStatusButton.layer.cornerRadius = 12
        setStatusButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        setStatusButton.translatesAutoresizingMaskIntoConstraints = false
        setStatusButton.layer.shadowColor = UIColor.black.cgColor
        setStatusButton.layer.shadowRadius = 4
        setStatusButton.layer.shadowOpacity = 0.7
        setStatusButton.layer.shadowOffset = CGSize(width: 4, height: 4)
        setStatusButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
        // Добавляем элементы
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(statusLabel)
        addSubview(statusTextField)
        addSubview(setStatusButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Аватар 100x100
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),

            // Имя справа от аватара
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 27),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Текущий статус под именем (все ещё справа от аватара)
            statusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 27),
            statusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            // Поле ввода под подписью, но В ПРЕДЕЛАХ высоты аватара
            statusTextField.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            statusTextField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            statusTextField.heightAnchor.constraint(equalToConstant: 40),
            statusTextField.bottomAnchor.constraint(lessThanOrEqualTo: avatarImageView.bottomAnchor, constant: 60),

            // Кнопка уже ниже аватара
            setStatusButton.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 40),
            setStatusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            setStatusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            setStatusButton.heightAnchor.constraint(equalToConstant: 50),
            setStatusButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
      

        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    
    
    // Обработка текста из TextField
    @objc private func statusTextChanged(_ textField: UITextField) {
        statusText = textField.text ?? ""
    }
    
    // Обработка нажатия кнопки
    @objc private func buttonPressed() {
        statusLabel.text = statusText
        print("Установлен статус: \(statusText)")
    }
    
    
    
}
    
    
    
    
    

