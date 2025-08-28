//
//  HomeActivityCell.swift
//  Coco
//
//  Created by Jackie Leonardy on 04/07/25.
//

import Foundation
import UIKit

final class HomeActivityCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(_ dataModel: HomeActivityCellDataModel) {
        imageView.loadImage(from: dataModel.imageUrl)
        nameLabel.text = dataModel.name
        let priceText = PriceFormatting.formattedIndonesianDecimal(from: dataModel.priceText)
        
        var areaText = dataModel.area
        if areaText.count > 17 { areaText = "\(areaText.prefix(17))..." }
        areaLabel.text = areaText
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6.0
        
        let adtData = AdditionalDataService.shared.getActivity(byId: dataModel.id)
        let labelText = adtData?.label
        badgeLabel.text = labelText
        
        // Set badge color based on label text
        switch labelText {
        case "Family":
            badgeView.backgroundColor = Token.mainColorLemon
        case "Couples":
            badgeView.backgroundColor = Token.pinkBadge
        case "Group":
            badgeView.backgroundColor = Token.blueBadge
        case "Solo":
            badgeView.backgroundColor = Token.orangeBadge
        default:
            badgeView.backgroundColor = Token.mainColorLemon
        }
        
        let attributedString = NSMutableAttributedString(
            string: "Starts from\n",
            attributes: [
                .font: UIFont.jakartaSans(forTextStyle: .callout, weight: .regular),
                .foregroundColor: Token.grayscale70,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        attributedString.append(NSMutableAttributedString(
            string: "Rp ",
            attributes: [
                .font: UIFont.jakartaSans(forTextStyle: .body, weight: .bold),
                .foregroundColor: Token.additionalColorsBlack
            ]
        ))
        
        attributedString.append(
            NSAttributedString(
                string: priceText,
                attributes: [
                    .font: UIFont.jakartaSans(forTextStyle: .body, weight: .bold),
                    .foregroundColor: Token.additionalColorsBlack
                ]
            )
        )
        
        attributedString.append(
            NSAttributedString(
                string: "/person",
                attributes: [
                    .font: UIFont.jakartaSans(forTextStyle: .callout, weight: .regular),
                    .foregroundColor: Token.grayscale70
                ]
            )
        )
        
        priceLabel.attributedText = attributedString
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        badgeView.backgroundColor = Token.mainColorLemon
    }
    
    private lazy var cardView: UIView = createCardView()
    private lazy var imageView: UIImageView = createImageView()
    private lazy var areaView: UIView = createAreaView()
    private lazy var badgeView: UIView = createBadgeView()
    
    private lazy var areaLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .callout, weight: .regular),
        textColor: Token.grayscale70,
        numberOfLines: 1
    )
    private lazy var nameLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .title3, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    private lazy var priceLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    private lazy var badgeLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .subheadline, weight: .medium),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 1
    )
}

private extension HomeActivityCell {
    func setupView() {
        // Card
        contentView.addSubview(cardView)
        cardView.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }
        
        // Image
        cardView.addSubview(imageView)
        imageView.layout {
            $0.top(to: cardView.topAnchor)
                .leading(to: cardView.leadingAnchor)
                .trailing(to: cardView.trailingAnchor)
        }
        
        // Badge
        cardView.addSubview(badgeView)
        badgeView.layout {
            $0.top(to: imageView.topAnchor, constant: 12)
                .leading(to: imageView.leadingAnchor, constant: 12)
        }
        
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        let stackView: UIStackView = UIStackView(
            arrangedSubviews: [
                nameLabel,
                areaView,
                spacerView,
                priceLabel
            ]
        )
        stackView.spacing = 8.0
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        cardView.addSubview(stackView)
        stackView.layout {
            $0.top(to: imageView.bottomAnchor, constant: 12)
                .leading(to: cardView.leadingAnchor, constant: 12)
                .trailing(to: cardView.trailingAnchor, constant: -12)
                .bottom(to: cardView.bottomAnchor, constant: -12)
                .height(150)
        }
    }
    
    func createCardView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12.0
        view.layer.borderWidth = 0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4.0
        view.clipsToBounds = false
        return view
    }
    
    func createImageView() -> UIImageView {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layout { $0.height(170.0) }
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12.0
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return imageView
    }
    
    func createAreaView() -> UIView {
        // -------- Icon
        let iconImageView: UIImageView = UIImageView(image: CocoIcon.icActivityAreaIcon.image)
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layout {
            $0.size(15)
        }
        
        let bulletDividerLabel = UILabel(
            font: .jakartaSans(forTextStyle: .callout, weight: .regular),
            textColor: Token.additionalColorsLine
        )
        bulletDividerLabel.text = "•"
        
        let rateIcon: UIImageView = UIImageView(image: CocoIcon.icStarred.image)
        rateIcon.contentMode = .scaleAspectFill
        rateIcon.layout {
            $0.size(15)
        }
        
        let staticReviewLabel = UILabel(
            font: .jakartaSans(forTextStyle: .callout, weight: .regular),
            textColor: Token.grayscale80
        )
        staticReviewLabel.text = "4.5"
        
        // -------- Container & Layout
        let containerView: UIView = UIView()
        containerView.addSubviews([
            iconImageView,
            areaLabel,
            bulletDividerLabel,
            rateIcon,
            staticReviewLabel
        ])
        
        iconImageView.layout {
            $0.leading(to: containerView.leadingAnchor)
                .top(to: containerView.topAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        
        areaLabel.layout {
            $0.leading(to: iconImageView.trailingAnchor, constant: 4.0)
                .centerY(to: containerView.centerYAnchor)
        }
        
        bulletDividerLabel.layout {
            $0.leading(to: areaLabel.trailingAnchor, constant: 6.0)
                .centerY(to: containerView.centerYAnchor)
        }
        
        rateIcon.layout {
            $0.leading(to: bulletDividerLabel.trailingAnchor, constant: 6.0)
                .centerY(to: containerView.centerYAnchor)
        }
        
        staticReviewLabel.layout {
            $0.leading(to: rateIcon.trailingAnchor, constant: 4.0)
                .centerY(to: containerView.centerYAnchor)
                .trailing(to: containerView.trailingAnchor, relation: .lessThanOrEqual)
        }
        
        return containerView
    }
    
    func createBadgeView() -> UIView {
        let view = UIView()
        view.backgroundColor = Token.mainColorLemon
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        
        view.addSubview(badgeLabel)
        badgeLabel.layout {
            $0.top(to: view.topAnchor, constant: 4)
                .leading(to: view.leadingAnchor, constant: 10)
                .trailing(to: view.trailingAnchor, constant: -10)
                .bottom(to: view.bottomAnchor, constant: -4)
        }
        
        return view
    }
    
    func configureWithActivityId(_ activityId: Int) {
        guard let activity = AdditionalDataService.shared.getActivity(byId: activityId) else {
            return
        }
        
        let dataModel = HomeActivityCellDataModel.from(activity: activity)
        configureCell(dataModel)
    }
    
}
