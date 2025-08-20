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
    
    func createHighlightsSection(description: UILabel) -> UIView {
        let contentView = UIView()
        
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 1
        )
        titleLabel.text = "Highlights"
        
        let seeMoreButton = UIButton()
        var config = UIButton.Configuration.bordered()
        config.title = "See More"
        config.baseBackgroundColor = UIColor.clear
        config.baseForegroundColor = Token.mainColorPrimary
        config.cornerStyle = .medium
        config.buttonSize = .small
        
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let chevronImage = UIImage(systemName: "chevron.down", withConfiguration: chevronConfig)
        config.image = chevronImage
        config.imagePlacement = .leading
        config.imagePadding = 4
        
        seeMoreButton.configuration = config
        seeMoreButton.layer.borderColor = Token.mainColorPrimary.cgColor
        seeMoreButton.layer.borderWidth = 1
        seeMoreButton.layer.cornerRadius = 16
        seeMoreButton.addTarget(self, action: #selector(seeMoreButtonTapped), for: .touchUpInside)
        
        contentView.addSubviews([titleLabel, description, seeMoreButton])
        
        titleLabel.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        description.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 8)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        seeMoreButton.layout {
            $0.top(to: description.bottomAnchor, constant: 12)
                .leading(to: contentView.leadingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }
        
        return contentView
    }
    
    func createTitleView() -> UIView {
        let chipLabel = createChipLabel(text: "Family Friendly", backgroundColor: UIColor.from("#C6F55C"))
        
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
        
        let contentView = UIView()
        contentView.addSubviews([chipLabel, titleLabel, locationRatingStackView])
        
        chipLabel.layout {
            $0.leading(to: contentView.leadingAnchor)
                .top(to: contentView.topAnchor)
        }
        
        titleLabel.layout {
            $0.leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .top(to: chipLabel.bottomAnchor, constant: 8)
        }
        
        locationRatingStackView.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 8)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor, relation: .lessThanOrEqual)
                .bottom(to: contentView.bottomAnchor)
        }
        
        return contentView
    }
    
    @objc func seeMoreButtonTapped() {
        delegate?.notifyHighlightsSeeMoreDidTap()
    }
}
