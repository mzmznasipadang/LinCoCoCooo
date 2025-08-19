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
        areaLabel.text = dataModel.area
        nameLabel.text = dataModel.name
        let priceText = PriceFormatting.formattedIndonesianDecimal(from: dataModel.priceText)
        
        let attributedString = NSMutableAttributedString(
            string: "Rp ",
            attributes: [
                .font: UIFont.jakartaSans(forTextStyle: .body, weight: .bold),
                .foregroundColor: Token.additionalColorsBlack
            ]
        )
        
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
                string: "/Person",
                attributes: [
                    .font: UIFont.jakartaSans(forTextStyle: .callout, weight: .regular),
                    .foregroundColor: Token.additionalColorsBlack
                ]
            )
        )
        
        priceLabel.attributedText = attributedString
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    private lazy var cardView: UIView = createCardView()
    private lazy var imageView: UIImageView = createImageView()
    private lazy var areaView: UIView = createAreaView()
    private lazy var areaLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .callout, weight: .regular),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
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
        
        let stackView: UIStackView = UIStackView(
            arrangedSubviews: [
                nameLabel,
                areaView,
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
        }
    }
    
    func createCardView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = Token.additionalColorsLine.cgColor
        view.clipsToBounds = true
        return view
    }
    
    func createImageView() -> UIImageView {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layout { $0.height(170.0) }
        imageView.clipsToBounds = true
        return imageView
    }
    
    func createAreaView() -> UIView {
        let iconImageView: UIImageView = UIImageView(image: CocoIcon.icActivityAreaIcon.image)
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layout {
            $0.size(20)
        }
        
        let containerView: UIView = UIView()
        containerView.addSubviews([
            iconImageView,
            areaLabel
        ])
        
        iconImageView.layout {
            $0.leading(to: containerView.leadingAnchor)
                .top(to: containerView.topAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        
        areaLabel.layout {
            $0.leading(to: iconImageView.trailingAnchor, constant: 4.0)
                .centerY(to: containerView.centerYAnchor)
                .trailing(to: containerView.trailingAnchor, relation: .lessThanOrEqual)
        }
        
        return containerView
    }
}
