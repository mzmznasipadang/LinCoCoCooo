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
        let containerStackView = createStackView(spacing: 12.0, axis: .horizontal)
        let contentStackView = createStackView(spacing: 10.0)
        
        let headerStackView = createStackView(spacing: 12.0)
        headerStackView.alignment = .leading
        
        let footerContentView = UIView()
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layout {
            $0.size(92.0)
        }
        imageView.layer.cornerRadius = 14.0
        imageView.loadImage(from: URL(string: data.imageUrlString))
        imageView.clipsToBounds = true
        
        let nameLabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 2
        )
        nameLabel.text = data.name
        
        let ratingAreaStackView = createStackView(spacing: 4.0, axis: .horizontal)
        ratingAreaStackView.alignment = .leading
        
        ratingAreaStackView.addArrangedSubview(
            createIconTextView(
                image: CocoIcon.icActivityAreaIcon.getImageWithTintColor(Token.grayscale70),
                text: data.description
            )
        )
        
        let priceLabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 2
        )
        
        let attributedString = NSMutableAttributedString(
            string: data.price,
            attributes: [
                .font: UIFont.jakartaSans(forTextStyle: .subheadline, weight: .bold),
                .foregroundColor: Token.additionalColorsBlack
            ]
        )
        
        attributedString.append(
            NSAttributedString(
                string: "/Person",
                attributes: [
                    .font: UIFont.jakartaSans(forTextStyle: .subheadline, weight: .medium),
                    .foregroundColor: Token.grayscale60
                ]
            )
        )
        
        priceLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        priceLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        priceLabel.attributedText = attributedString
        
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(contentStackView)
        
        contentStackView.addArrangedSubview(headerStackView)
        contentStackView.addArrangedSubview(footerContentView)
        
        headerStackView.addArrangedSubview(nameLabel)
        headerStackView.addArrangedSubview(ratingAreaStackView)
        
        let action = UIAction { [weak self] _ in
            self?.delegate?.notifyPackagesDetailDidTap(with: data.id)
        }
         
        var config = UIButton.Configuration.filled()
        config.image = CocoIcon.icArrowTopRight.image
        config.baseBackgroundColor = Token.mainColorPrimary
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule

        let button = UIButton(configuration: config, primaryAction: action)
        button.layout {
            $0.size(40.0)
        }
        
        button.setContentHuggingPriority(.required + 1, for: .horizontal)
        button.setContentHuggingPriority(.required + 1, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        
        footerContentView.addSubviews([priceLabel, button])
        
        priceLabel.layout {
            $0.leading(to: footerContentView.leadingAnchor)
                .top(to: footerContentView.topAnchor)
                .bottom(to: footerContentView.bottomAnchor)
        }
        
        button.layout {
            $0.leading(to: priceLabel.trailingAnchor, relation: .lessThanOrEqual)
                .centerY(to: footerContentView.centerYAnchor)
                .trailing(to: footerContentView.trailingAnchor)
        }
        
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.layoutMargins = .init(edges: 12.0)
        containerStackView.layer.cornerRadius = 16.0
        containerStackView.backgroundColor = Token.mainColorForth
        
        return containerStackView
    }
    
    func createPackageSection() -> UIView {
        let containerView = UIView()
        containerView.addSubviews([packageLabel, packageButton])
        
        packageButton.setContentHuggingPriority(.required, for: .horizontal)
        packageButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        packageLabel.layout {
            $0.leading(to: containerView.leadingAnchor)
                .top(to: containerView.topAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        
        packageButton.layout {
            $0.leading(to: packageLabel.trailingAnchor, constant: 4.0)
                .trailing(to: containerView.trailingAnchor)
                .centerY(to: containerView.centerYAnchor)
        }
        
        let contentView = UIView()
        contentView.addSubviews([containerView, packageContainer])
        
        containerView.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        packageContainer.layout {
            $0.top(to: containerView.bottomAnchor, constant: 16.0)
                .bottom(to: contentView.bottomAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        return contentView
    }
    
    func createPackageTextButton() -> UIButton {
        let textButton = UIButton.textButton(title: "Show All")
        textButton.addTarget(self, action: #selector(didTapTextButton), for: .touchUpInside)
        return textButton
    }
    
    @objc func didTapTextButton() {
        isPackageButtonStateHidden.toggle()
        packageButton.setTitle(isPackageButtonStateHidden ? "Show All" : "Show Less", for: .normal)
        delegate?.notifyPackagesButtonDidTap(shouldShowAll: !isPackageButtonStateHidden)
    }
}
