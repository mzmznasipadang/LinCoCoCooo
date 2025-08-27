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
    
    private func excerpt(from text: String, maxWords: Int = 14) -> String {
        let words = text.split { $0.isNewline || $0.isWhitespace }
        guard words.count > maxWords else { return text }
        return words.prefix(maxWords).joined(separator: " ") + "…"
    }
    
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
    
    func createTitleView(with labelText: String?) -> UIView {
        let contentView = UIView()
        var currentTopAnchor = contentView.topAnchor
        var topSpacing: CGFloat = 0
        if let labelText = labelText, !labelText.isEmpty {
            let (text, color) = badgeStyle(for: labelText)
            let chipLabel = createChipLabel(text: text, backgroundColor: color)
            
            contentView.addSubview(chipLabel)
            chipLabel.layout {
                $0.leading(to: contentView.leadingAnchor)
                $0.top(to: currentTopAnchor)
                $0.trailing(to: contentView.trailingAnchor, relation: .lessThanOrEqual)
            }
            currentTopAnchor = chipLabel.bottomAnchor
            topSpacing = 8
        }
        
        let pinPointImage = UIImageView(image: CocoIcon.icActivityAreaIcon.image)
        pinPointImage.layout {
            $0.size(20.0)
        }
        
        let starImage = UIImageView(image: CocoIcon.icStarred.image)
        starImage.layout {
            $0.size(16.0)
        }
        
        let ratingLabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale90,
            numberOfLines: 1
        )
        ratingLabel.text = "4.5"
        
        let locationRatingStackView = UIStackView()
        locationRatingStackView.axis = .horizontal
        locationRatingStackView.spacing = 16
        locationRatingStackView.alignment = .center
        
        let locationView = UIView()
        locationView.addSubviews([pinPointImage, locationLabel])
        
        pinPointImage.layout {
            $0.leading(to: locationView.leadingAnchor)
                .centerY(to: locationView.centerYAnchor)
        }
        
        locationLabel.layout {
            $0.leading(to: pinPointImage.trailingAnchor, constant: 4)
                .trailing(to: locationView.trailingAnchor)
                .centerY(to: locationView.centerYAnchor)
                .top(to: locationView.topAnchor)
                .bottom(to: locationView.bottomAnchor)
        }
        
        let ratingView = UIView()
        ratingView.addSubviews([starImage, ratingLabel])
        
        starImage.layout {
            $0.leading(to: ratingView.leadingAnchor)
                .centerY(to: ratingView.centerYAnchor)
        }
        
        ratingLabel.layout {
            $0.leading(to: starImage.trailingAnchor, constant: 4)
                .trailing(to: ratingView.trailingAnchor)
                .centerY(to: ratingView.centerYAnchor)
                .top(to: ratingView.topAnchor)
                .bottom(to: ratingView.bottomAnchor)
        }
        
        locationRatingStackView.addArrangedSubview(locationView)
        locationRatingStackView.addArrangedSubview(ratingView)
        
        contentView.addSubviews([titleLabel, locationRatingStackView])
        
        titleLabel.layout {
            $0.leading(to: contentView.leadingAnchor)
            $0.trailing(to: contentView.trailingAnchor)
            $0.top(to: currentTopAnchor, constant: topSpacing)
        }
        
        locationRatingStackView.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 8)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor, relation: .lessThanOrEqual)
                .bottom(to: contentView.bottomAnchor)
        }
        
        return contentView
    }
    
    // Create Highlights Section
    func createHighlightsSection(fullText: String) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.from("#E8F6FD")
        card.layer.cornerRadius = 16

        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 1
        )
        titleLabel.text = "Highlights"

        let previewText = "“" + excerpt(from: fullText, maxWords: 14) + "”"
        let quoteLabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .regular),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 0
        )
        quoteLabel.font = {
            let base = UIFont.jakartaSans(forTextStyle: .subheadline, weight: .regular)
            let desc = base.fontDescriptor.withSymbolicTraits(.traitItalic) ?? base.fontDescriptor
            return UIFont(descriptor: desc, size: base.pointSize)
        }()
        quoteLabel.text = previewText

        let seeMoreButton = UIButton(type: .system)
        seeMoreButton.setTitle("See more", for: .normal)
        seeMoreButton.setTitleColor(Token.mainColorPrimary, for: .normal)
        seeMoreButton.titleLabel?.font = .jakartaSans(forTextStyle: .footnote, weight: .semibold)
        seeMoreButton.contentHorizontalAlignment = .leading
        seeMoreButton.addTarget(self, action: #selector(seeMoreButtonTapped), for: .touchUpInside)

        self.highlightsFullText = fullText

        card.addSubviews([titleLabel, quoteLabel, seeMoreButton])
        titleLabel.layout {
            $0.top(to: card.topAnchor, constant: 16)
                .leading(to: card.leadingAnchor, constant: 16)
                .trailing(to: card.trailingAnchor, constant: -16)
        }
        quoteLabel.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 8)
                .leading(to: card.leadingAnchor, constant: 16)
                .trailing(to: card.trailingAnchor, constant: -16)
        }
        seeMoreButton.layout {
            $0.top(to: quoteLabel.bottomAnchor, constant: 12)
                .leading(to: card.leadingAnchor, constant: 16)
                .bottom(to: card.bottomAnchor, constant: -16)
        }

        return card
    }
    
    // Create Package View Container
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
        
        let perPersonLabel = UILabel(
            font: .jakartaSans(forTextStyle: .caption1, weight: .regular),
            textColor: Token.grayscale70
        )
        perPersonLabel.text = "per person"
        
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
        
        let priceStack = UIStackView(arrangedSubviews: [priceLabel, perPersonLabel])
        priceStack.axis = .vertical
        priceStack.spacing = 0
        priceStack.alignment = .leading
        
        cardView.addSubviews([imageView, infoStack, priceStack, detailsButton, bookButton])
        
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
        
        priceStack.layout {
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
        
        let tagView = createChipLabel(text: "Family", backgroundColor: Token.mainColorLemon)
        (tagView.subviews.first as? UILabel)?.textColor = UIColor.black
        
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
        packageLabel.font = .jakartaSans(forTextStyle: .subheadline, weight: .semibold)
        packageLabel.textColor = .secondaryLabel
        
        let reviewTextLabel = UILabel()
        reviewTextLabel.text = "Perfect family trip! Safe, fun, and the kids loved seeing the colorful fish in Piaynemo."
        reviewTextLabel.font = .jakartaSans(forTextStyle: .body, weight: .regular)
        reviewTextLabel.numberOfLines = 0
        
        let seeMoreButton = UIButton.textButton(title: "See more", color: Token.mainColorPrimary)
        
        let imageGalleryStack = UIStackView()
        imageGalleryStack.axis = .horizontal
        imageGalleryStack.spacing = 8
        imageGalleryStack.distribution = .fillEqually
        
        for i in 1...3 {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "Review\(i)")
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
    
    private func badgeStyle(for label: String) -> (text: String, color: UIColor) {
        switch label.lowercased() {
        case "family":
            return ("Family Friendly", Token.mainColorLemon)
        case "couples":
            return ("Couples Getaway", Token.pinkBadge)
        case "group":
            return ("Group Fun", Token.orangeBadge)
        case "solo":
            return ("Solo Adventure", Token.blueBadge)
        default:
            return (label, .systemGray4)
        }
    }
    
    private struct AssociatedKeys { static var highlightsText = "hlFull" }
    private var highlightsFullText: String? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.highlightsText) as? String }
        set { objc_setAssociatedObject(self, &AssociatedKeys.highlightsText, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    @objc func seeMoreButtonTapped() {
        delegate?.notifyHighlightsSeeMoreDidTap(fullText: highlightsFullText ?? "")
    }
}

private extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
