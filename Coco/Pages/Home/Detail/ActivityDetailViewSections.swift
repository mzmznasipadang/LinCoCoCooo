//
//  ActivityDetailViewSections.swift
//  Coco
//
//  Created by Lin Dan Christiano on 20/08/25.
//

import Foundation
import UIKit

// MARK: - Section Creation Methods
extension ActivityDetailView {
    
    private func excerpt(from text: String, maxWords: Int = 14) -> String {
        let words = text.split { $0.isNewline || $0.isWhitespace }
        guard words.count > maxWords else { return text }
        return words.prefix(maxWords).joined(separator: " ") + "…"
    }

    private func italicFont(from base: UIFont) -> UIFont {
        let desc = base.fontDescriptor.withSymbolicTraits(.traitItalic) ?? base.fontDescriptor
        return UIFont(descriptor: desc, size: base.pointSize)
    }
    
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
        
        let pinPointImage = UIImageView(image: CocoIcon.icPinPointBlue.image)
        pinPointImage.layout {
            $0.size(20.0)
        }
        
        let starImage = UIImageView(image: CocoIcon.icStarRating.image)
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
