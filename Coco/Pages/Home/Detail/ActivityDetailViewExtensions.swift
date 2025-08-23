//
//  Activity.swift
//  Coco
//
//  Created by Lin Dan Christiano on 20/08/25.
//

import Foundation
import UIKit

// MARK: - UI Creation Methods
extension ActivityDetailView {
    
    func createChipLabel(text: String, backgroundColor: UIColor) -> UIView {
        let label = UILabel(
            font: .jakartaSans(forTextStyle: .caption1, weight: .medium),
            textColor: .black,
            numberOfLines: 1
        )
        label.text = text
        
        let containerView = UIView()
        containerView.backgroundColor = backgroundColor
        containerView.layer.cornerRadius = 12
        containerView.addSubviewAndLayout(label, insets: .init(top: 6, left: 12, bottom: 6, right: 12))
        
        return containerView
    }
    
    func createDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = Token.grayscale30
        divider.layout {
            $0.height(1)
        }
        return divider
    }
    
    func createStackView(
        spacing: CGFloat,
        axis: NSLayoutConstraint.Axis = .vertical
    ) -> UIStackView {
        let stackView = UIStackView()
        stackView.spacing = spacing
        stackView.axis = axis
        return stackView
    }
    
    func createSectionView(title: String, view: UIView) -> UIView {
        let contentView = UIView()
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 2
        )
        titleLabel.text = title
        
        contentView.addSubviews([titleLabel, view])
        
        titleLabel.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        view.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 8.0)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }
        
        return contentView
    }
    
    func createIconTextView(image: UIImage, text: String) -> UIView {
        let imageView = UIImageView(image: image)
        imageView.layout {
            $0.size(20.0)
        }
        
        let label = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale90,
            numberOfLines: 2
        )
        label.text = text
        
        let containerView = UIView()
        containerView.addSubviews([imageView, label])
        
        imageView.layout {
            $0.leading(to: containerView.leadingAnchor)
                .centerY(to: containerView.centerYAnchor)
        }
        
        label.layout {
            $0.leading(to: imageView.trailingAnchor, constant: 4.0)
                .trailing(to: containerView.trailingAnchor)
                .centerY(to: containerView.centerYAnchor)
        }
        
        return containerView
    }
    
    // MARK: - Promo Section
    func createPromoSection() -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = "Promo"
        titleLabel.font = .jakartaSans(forTextStyle: .headline, weight: .bold)
        titleLabel.textColor = Token.additionalColorsBlack
        
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        
        let imageStackView = UIStackView()
        imageStackView.axis = .horizontal
        imageStackView.spacing = 16
        
        let promoImageNames = ["Banner1", "Banner2", "Banner3", "Banner4"]
        
        for imageName in promoImageNames {
            let imageView = UIImageView()
            imageView.image = UIImage(named: imageName)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 280),
                imageView.heightAnchor.constraint(equalToConstant: 160)
            ])
            
            imageStackView.addArrangedSubview(imageView)
        }
        
        scrollView.addSubview(imageStackView)
        imageStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        let mainStackView = createStackView(spacing: 16)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(scrollView)
        
        return mainStackView
    }
    
    func createReviewSection() -> UIView {
        let mainStack = createStackView(spacing: 16, axis: .vertical)
        
        let headerView = createReviewHeaderView()
        let overallRatingView = createOverallRatingView()
        let reviewCard = createReviewCard()
        
        mainStack.addArrangedSubview(headerView)
        mainStack.addArrangedSubview(overallRatingView)
        mainStack.addArrangedSubview(reviewCard)
        
        return mainStack
    }
    
    // create header review
    private func createReviewHeaderView() -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = "Review"
        titleLabel.font = .jakartaSans(forTextStyle: .headline, weight: .bold)
        titleLabel.textColor = Token.additionalColorsBlack
        
        let seeAllButton = UIButton.textButton(title: "See All", color: .systemGray)
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, seeAllButton])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing
        
        return headerStack
    }
    
    private func createOverallRatingView() -> UIView {
        let ratingLabel = UILabel()
        ratingLabel.text = "4.8"
        ratingLabel.font = .jakartaSans(forTextStyle: .headline, weight: .bold)
        
        let maxRatingLabel = UILabel()
        maxRatingLabel.text = "/5.0"
        maxRatingLabel.font = .jakartaSans(forTextStyle: .subheadline, weight: .regular)
        maxRatingLabel.textColor = .systemGray
        
        let reviewCountLabel = UILabel()
        reviewCountLabel.text = "• 16 reviews"
        reviewCountLabel.font = .jakartaSans(forTextStyle: .subheadline, weight: .regular)
        reviewCountLabel.textColor = .systemGray
        
        let ratingStack = UIStackView(arrangedSubviews: [ratingLabel, maxRatingLabel, reviewCountLabel])
        ratingStack.axis = .horizontal
        ratingStack.spacing = 4
        ratingStack.alignment = .firstBaseline
        
        return ratingStack
    }
    
    private func createReviewCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.borderColor = UIColor.systemGray6.cgColor
        card.layer.borderWidth = 1
        
        let nameLabel = UILabel()
        nameLabel.text = "Linda"
        nameLabel.font = .jakartaSans(forTextStyle: .headline, weight: .semibold)
        
        let tagView = createChipLabel(text: "Family", backgroundColor: UIColor.systemGreen.withAlphaComponent(0.2))
        (tagView.subviews.first as? UILabel)?.textColor = .systemGreen
        
        let topStack = UIStackView(arrangedSubviews: [nameLabel, tagView])
        topStack.spacing = 8
        topStack.alignment = .center
        
        let starStack = UIStackView()
        starStack.axis = .horizontal
        starStack.spacing = 2
        for _ in 1...5 {
            let star = UIImageView(image: UIImage(systemName: "star.fill"))
            star.tintColor = .systemYellow
            starStack.addArrangedSubview(star)
        }
        
        let packageLabel = UILabel()
        packageLabel.text = "Package: Family Fun Snorkel"
        packageLabel.font = .jakartaSans(forTextStyle: .subheadline, weight: .regular)
        packageLabel.textColor = .secondaryLabel
        
        let reviewTextLabel = UILabel()
        reviewTextLabel.text = "Perfect family trip! Safe, fun, and the kids loved seeing the colorful fish in Piaynemo."
        reviewTextLabel.font = .jakartaSans(forTextStyle: .body, weight: .regular)
        reviewTextLabel.numberOfLines = 0 // Biarkan bisa lebih dari 1 baris
        
        let seeMoreButton = UIButton.textButton(title: "See more", color: Token.mainColorPrimary)
        
        let imageGalleryStack = UIStackView()
        imageGalleryStack.axis = .horizontal
        imageGalleryStack.spacing = 8
        imageGalleryStack.distribution = .fillEqually
        
        for _ in 1...3 {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
            imageView.tintColor = .systemGray4
            imageView.backgroundColor = .systemGray6
            imageView.contentMode = .center
            imageView.layer.cornerRadius = 12
            imageView.clipsToBounds = true
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
            imageGalleryStack.addArrangedSubview(imageView)
        }
        
        let cardContentStack = createStackView(spacing: 12, axis: .vertical)
        cardContentStack.alignment = .leading
        
        cardContentStack.addArrangedSubview(topStack)
        cardContentStack.addArrangedSubview(starStack)
        cardContentStack.addArrangedSubview(packageLabel)
        cardContentStack.addArrangedSubview(reviewTextLabel)
        cardContentStack.addArrangedSubview(seeMoreButton)
        cardContentStack.addArrangedSubview(imageGalleryStack)
        
        imageGalleryStack.widthAnchor.constraint(equalTo: cardContentStack.widthAnchor).isActive = true

        card.addSubviewAndLayout(cardContentStack, insets: .init(edges: 16))
        
        return card
    }
}
