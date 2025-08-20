//
//  PackageInfoCell.swift
//  Coco
//
//  Created by Victor Chandra on 20/08/25.
//

import Foundation
import UIKit

// MARK: - Package Info Cell (Top Card)
final class PackageInfoCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configures the cell with data for displaying package information.
    func configure(with data: PackageInfoDisplayData) {
        packageImageView.loadImage(from: URL(string: data.imageUrl))
        packageNameLabel.text = data.packageName
        paxLabel.text = data.paxRange
        priceLabel.text = "\(data.pricePerPax)"
        
        // Handle discount price visibility and text
        if let originalPrice = data.originalPrice, data.hasDiscount {
            let attributeString = NSAttributedString(
                string: "\(originalPrice)",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            originalPriceLabel.attributedText = attributeString
            originalPriceLabel.isHidden = false
        } else {
            originalPriceLabel.isHidden = true
        }
    }
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Token.additionalColorsWhite
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private lazy var packageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = Token.grayscale20
        return imageView
    }()
    
    private lazy var packageNameLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .headline, weight: .bold),
        textColor: Token.grayscale90,
        numberOfLines: 2
    )
    
    private lazy var paxIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.2.fill")
        imageView.tintColor = Token.grayscale50
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var paxLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale50,
        numberOfLines: 1
    )
    
    private lazy var priceLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .title3, weight: .bold),
        textColor: Token.grayscale90,
        numberOfLines: 1
    )
    
    private lazy var originalPriceLabel: UILabel = {
        let label = UILabel(
            font: .jakartaSans(forTextStyle: .callout, weight: .regular),
            textColor: Token.grayscale50,
            numberOfLines: 1
        )
        label.isHidden = true
        return label
    }()
    
    // MARK: - Setup
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubviews([
            packageImageView,
            packageNameLabel,
            paxIconImageView,
            paxLabel,
            priceLabel,
            originalPriceLabel
        ])
        
        // Layout
        containerView.layout {
            $0.top(to: contentView.topAnchor, constant: 8)
            $0.leading(to: contentView.leadingAnchor, constant: 16)
            $0.trailing(to: contentView.trailingAnchor, constant: -16)
            $0.bottom(to: contentView.bottomAnchor, constant: -8)
        }
        
        packageImageView.layout {
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.top(to: containerView.topAnchor, constant: 16)
            $0.bottom(to: containerView.bottomAnchor, relation: .lessThanOrEqual, constant: -16)
            $0.width(100)
            $0.height(100)
        }
        
        packageNameLabel.layout {
            $0.leading(to: packageImageView.trailingAnchor, constant: 16)
            $0.top(to: containerView.topAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        paxIconImageView.layout {
            $0.leading(to: packageImageView.trailingAnchor, constant: 16)
            $0.top(to: packageNameLabel.bottomAnchor, constant: 8)
            $0.size(16) // Corrected size
        }
        
        paxLabel.layout {
            $0.leading(to: paxIconImageView.trailingAnchor, constant: 4)
            $0.centerY(to: paxIconImageView.centerYAnchor)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        priceLabel.layout {
            $0.leading(to: packageImageView.trailingAnchor, constant: 16)
            $0.top(to: paxIconImageView.bottomAnchor, constant: 16)
            $0.bottom(to: containerView.bottomAnchor, constant: -16)
        }
        
        originalPriceLabel.layout {
            $0.leading(to: priceLabel.trailingAnchor, constant: 8)
            $0.centerY(to: priceLabel.centerYAnchor)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
    }
}
