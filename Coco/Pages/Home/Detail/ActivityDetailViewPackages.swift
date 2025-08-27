//
//  ActivityDetailViewPackages.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import UIKit

// MARK: - Package Related Methods
extension ActivityDetailView {
    
    func createBenefitView(title: String) -> UIView {
        let contentView = UIView()
        let benefitImageView = UIImageView(image: CocoIcon.icCheckMarkFill.image)
        benefitImageView.layout {
            $0.size(24.0)
        }
        let benefitLabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 0
        )
        benefitLabel.text = title
        
        contentView.addSubviews([benefitImageView, benefitLabel])
        
        benefitImageView.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .bottom(to: contentView.bottomAnchor, relation: .lessThanOrEqual)
        }
        
        benefitLabel.layout {
            $0.leading(to: benefitImageView.trailingAnchor, constant: 4.0)
                .top(to: contentView.topAnchor)
                .bottom(to: contentView.bottomAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        return contentView
    }
    
    func createBenefitListView(titles: [String]) -> UIView {
        let stackView = createStackView(spacing: 12.0)
        
        titles.forEach { title in
            stackView.addArrangedSubview(createBenefitView(title: title))
        }
        
        return stackView
    }
    
    func createProviderDetail(imageUrl: String, name: String, description: String) -> UIView {
        let contentView = UIView()
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layout {
            $0.size(92.0)
        }
        imageView.layer.cornerRadius = 14.0
        imageView.loadImage(from: URL(string: imageUrl))
        imageView.clipsToBounds = true
        
        let nameLabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 2
        )
        nameLabel.text = name
        
        let descriptionLabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale90,
            numberOfLines: 0
        )
        descriptionLabel.text = description
        
        contentView.addSubviews([imageView, nameLabel, descriptionLabel])
        
        imageView.layout {
            $0.leading(to: contentView.leadingAnchor)
                .top(to: contentView.topAnchor)
                .bottom(to: contentView.bottomAnchor, relation: .lessThanOrEqual)
        }
        
        nameLabel.layout {
            $0.leading(to: imageView.trailingAnchor, constant: 10.0)
                .top(to: contentView.topAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        descriptionLabel.layout {
            $0.leading(to: nameLabel.leadingAnchor)
                .top(to: nameLabel.bottomAnchor, constant: 8.0)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor, relation: .lessThanOrEqual)
        }
        
        return contentView
    }
    
    func createPackageView(data: ActivityDetailDataModel.Package) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray6.cgColor
        cardView.isUserInteractionEnabled = true
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.loadImage(from: URL(string: data.imageUrlString))
        
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .headline, weight: .semibold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 2
        )
        titleLabel.text = data.name
        
        let paxLabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .regular),
            textColor: Token.grayscale70
        )
        paxLabel.text = data.description
        
        let paxIcon = UIImageView(image: UIImage(systemName: "person.fill"))
        paxIcon.tintColor = Token.grayscale70
        paxIcon.contentMode = .scaleAspectFit
        
        let priceLabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
            textColor: Token.additionalColorsBlack
        )
        priceLabel.text = data.price
        
        let detailsButton = UIButton.textButton(title: "Details", color: Token.mainColorPrimary)
        detailsButton.isEnabled = true
        detailsButton.isUserInteractionEnabled = true
        let detailsAction = UIAction { [weak self] _ in
            self?.delegate?.notifyPackageDetailsDidTap(with: data.id)
        }
        detailsButton.addAction(detailsAction, for: .touchUpInside)
        
        let bookButton = UIButton(type: .system)
        bookButton.setTitle("Book", for: .normal)
        bookButton.backgroundColor = Token.mainColorPrimary
        bookButton.setTitleColor(.white, for: .normal)
        bookButton.titleLabel?.font = .jakartaSans(forTextStyle: .subheadline, weight: .bold)
        bookButton.layer.cornerRadius = 12
        bookButton.isEnabled = true
        bookButton.isUserInteractionEnabled = true
        
        let bookAction = UIAction { [weak self] _ in
            self?.delegate?.notifyUserDidTapBookPackage(with: data.id)
        }
        bookButton.addAction(bookAction, for: .touchUpInside)
        
        // --- Layout ---
        let paxStack = UIStackView(arrangedSubviews: [paxIcon, paxLabel])
        paxStack.spacing = 6
        
        let infoStack = UIStackView(arrangedSubviews: [titleLabel, paxStack])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        infoStack.alignment = .leading
        
        cardView.addSubviews([imageView, infoStack, priceLabel, detailsButton, bookButton])
        
        imageView.layout {
            $0.leading(to: cardView.leadingAnchor, constant: 12)
            $0.centerY(to: cardView.centerYAnchor)
            $0.width(90)
            $0.height(120)
        }
        
        infoStack.layout {
            $0.leading(to: imageView.trailingAnchor, constant: 16)
            $0.top(to: imageView.topAnchor)
            $0.trailing(to: detailsButton.leadingAnchor, constant: -8)
        }
        
        detailsButton.layout {
            $0.top(to: cardView.topAnchor, constant: 12)
            $0.trailing(to: cardView.trailingAnchor, constant: -16)
        }
        
        priceLabel.layout {
            $0.leading(to: imageView.trailingAnchor, constant: 16)
            $0.bottom(to: cardView.bottomAnchor, constant: -12)
        }
        
        bookButton.layout {
            $0.trailing(to: cardView.trailingAnchor, constant: -16)
            $0.bottom(to: cardView.bottomAnchor, constant: -12)
            $0.width(90)
            $0.height(40)
        }
        
        cardView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        return cardView
    }
    
    func createPackageSection() -> UIView {
        let sectionStackView = createStackView(spacing: 16.0)
        
        sectionStackView.addArrangedSubview(packageLabel)
        sectionStackView.addArrangedSubview(packageContainer)
        
        return sectionStackView
    }
}

private extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
