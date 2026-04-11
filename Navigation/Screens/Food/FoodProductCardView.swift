import UIKit

final class FoodProductCardView: UIView {
    private let nameLabel = UILabel()
    private let nutrientsLabel = UILabel()
    private let ingredientsLabel = UILabel()
    private let allergensLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with product: FoodProduct) {
        nameLabel.text = product.name
        nutrientsLabel.text = L10n.format(
            "food.nutrients.format",
            product.nutrients.calories,
            product.nutrients.proteins,
            product.nutrients.fats,
            product.nutrients.carbs
        )
        ingredientsLabel.text = "\(L10n.tr("food.ingredients.title")): \(product.ingredients)"
        allergensLabel.text = "\(L10n.tr("food.allergens.title")): \(product.allergens.map(\.name).joined(separator: ", "))"
        isHidden = false
    }

    private func setupUI() {
        isHidden = true
        backgroundColor = StyleGuide.Colors.card
        layer.cornerRadius = 14
        layer.borderWidth = 0.5
        layer.borderColor = StyleGuide.Colors.border.cgColor

        let stack = UIStackView(arrangedSubviews: [nameLabel, nutrientsLabel, ingredientsLabel, allergensLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = StyleGuide.Fonts.body(18, weight: .semibold)
        nameLabel.textColor = StyleGuide.Colors.textPrimary
        nameLabel.numberOfLines = 2

        [nutrientsLabel, ingredientsLabel, allergensLabel].forEach {
            $0.font = StyleGuide.Fonts.caption(14, weight: .regular)
            $0.textColor = StyleGuide.Colors.textSecondary
            $0.numberOfLines = 0
        }

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
