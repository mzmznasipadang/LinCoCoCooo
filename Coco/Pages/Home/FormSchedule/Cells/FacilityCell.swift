//
//  FacilityCell.swift
//  Coco
//
//  Created by Victor Chandra on 20/08/25.
//

import Foundation
import UIKit

final class FacilityCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: FacilityDisplayItem) {
        iconImageView.image = UIImage(systemName: item.iconName)
        iconImageView.tintColor = item.isIncluded ? Token.alertsSuccess : Token.grayscale40
        
        nameLabel.text = item.name
        nameLabel.textColor = item.isIncluded ? Token.grayscale90 : Token.grayscale50
        
        descriptionLabel.text = item.description
        descriptionLabel.isHidden = item.description == nil
        
//        statusLabel.text = item.isIncluded ? "Included" : "Not Included"
//        statusLabel.textColor = item.isIncluded ? Token.alertsSuccess : Token.grayscale50
    }
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .callout, weight: .medium),
        textColor: Token.grayscale90,
        numberOfLines: 0
    )
    
    private lazy var descriptionLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .caption1, weight: .regular),
        textColor: Token.grayscale60,
        numberOfLines: 0
    )
    
    private lazy var statusLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .caption2, weight: .medium),
        textColor: Token.alertsSuccess,
        numberOfLines: 1
    )
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = Token.additionalColorsWhite
        
        contentView.addSubviews([
            iconImageView,
            nameLabel,
            descriptionLabel,
            statusLabel
        ])
        
        iconImageView.layout {
            $0.leading(to: contentView.leadingAnchor, constant: 16)
            $0.top(to: contentView.topAnchor, constant: 12)
            $0.size(24)
        }
        
        nameLabel.layout {
            $0.leading(to: iconImageView.trailingAnchor, constant: 12)
            $0.top(to: contentView.topAnchor, constant: 12)
            $0.trailing(to: statusLabel.leadingAnchor, constant: -8)
        }
        
        descriptionLabel.layout {
            $0.leading(to: nameLabel.leadingAnchor)
            $0.top(to: nameLabel.bottomAnchor, constant: 4)
            $0.trailing(to: contentView.trailingAnchor, constant: -16)
            $0.bottom(to: contentView.bottomAnchor, constant: -12)
        }
        
        statusLabel.layout {
            $0.trailing(to: contentView.trailingAnchor, constant: -16)
            $0.centerY(to: iconImageView.centerYAnchor)
        }
    }
}
