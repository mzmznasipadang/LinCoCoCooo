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
        
        // Format price with /person suffix to match Figma design
        let priceText = "\(data.pricePerPax)/person"
        let attributedString = NSMutableAttributedString(string: priceText)
        
        // Style the main price part (bold, black) - smaller font to match Image #2
        let priceRange = NSRange(location: 0, length: data.pricePerPax.count)
        attributedString.addAttribute(.font, value: UIFont.jakartaSans(forTextStyle: .body, weight: .bold), range: priceRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1), range: priceRange)
        
        // Style the /person suffix (smaller, gray)
        let suffixRange = NSRange(location: data.pricePerPax.count, length: 7) // "/person"
        attributedString.addAttribute(.font, value: UIFont.jakartaSans(forTextStyle: .caption1, weight: .medium), range: suffixRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1), range: suffixRange)
        
        priceLabel.attributedText = attributedString
        
        descriptionLabel.text = data.description
        
        // Set duration title and parse time range from duration
        durationTitleLabel.text = "Duration"
        
        // Parse duration string to extract time range - expecting format like "09:00-16:00 (7 Hours)"
        if let timeRange = extractTimeRange(from: data.duration) {
            timeRangeLabel.text = timeRange
        } else {
            timeRangeLabel.text = data.duration // Fallback to original format
        }
        
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
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 227/255, green: 231/255, blue: 236/255, alpha: 1).cgColor
        
        // Add shadow to match Figma design
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.masksToBounds = false
        
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
        font: .jakartaSans(forTextStyle: .headline, weight: .semibold),
        textColor: UIColor(red: 23/255, green: 23/255, blue: 37/255, alpha: 1),
        numberOfLines: 1
    )
    
    private lazy var paxIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var paxLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1),
        numberOfLines: 1
    )
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var originalPriceLabel: UILabel = {
        let label = UILabel(
            font: .jakartaSans(forTextStyle: .callout, weight: .regular),
            textColor: Token.grayscale50,
            numberOfLines: 1
        )
        label.isHidden = true
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: .black,
        numberOfLines: 0
    )
    
    private lazy var durationIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock")
        imageView.tintColor = UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var durationTitleLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1),
        numberOfLines: 1
    )
    
    private lazy var timeRangeLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1),
        numberOfLines: 1
    )
    
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
            originalPriceLabel,
            descriptionLabel,
            durationIconImageView,
            durationTitleLabel,
            timeRangeLabel
        ])
        
        // Layout with proper margins for card appearance
        containerView.layout {
            $0.top(to: contentView.topAnchor, constant: 16)
            $0.leading(to: contentView.leadingAnchor, constant: 24)
            $0.trailing(to: contentView.trailingAnchor, constant: -24)
            $0.bottom(to: contentView.bottomAnchor, constant: -8)
        }
        
        packageImageView.layout {
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.top(to: containerView.topAnchor, constant: 16)
            $0.width(80)   // 1:1 ratio
            $0.height(80)  // 1:1 ratio
        }
        
        packageNameLabel.layout {
            $0.leading(to: packageImageView.trailingAnchor, constant: 16)
            $0.top(to: containerView.topAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        paxIconImageView.layout {
            $0.leading(to: packageImageView.trailingAnchor, constant: 12)
            $0.top(to: packageNameLabel.bottomAnchor, constant: 6)
            $0.size(14)  // Increased by 2pt
        }
        
        paxLabel.layout {
            $0.leading(to: paxIconImageView.trailingAnchor, constant: 4)
            $0.centerY(to: paxIconImageView.centerYAnchor)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        priceLabel.layout {
            $0.leading(to: packageImageView.trailingAnchor, constant: 12)
            $0.top(to: paxIconImageView.bottomAnchor, constant: 8)
        }
        
        originalPriceLabel.layout {
            $0.leading(to: priceLabel.trailingAnchor, constant: 8)
            $0.centerY(to: priceLabel.centerYAnchor)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        descriptionLabel.layout {
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.top(to: packageImageView.bottomAnchor, constant: 8)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
        }
        
        durationIconImageView.layout {
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.top(to: descriptionLabel.bottomAnchor, constant: 8)
            $0.size(16)
        }
        
        durationTitleLabel.layout {
            $0.leading(to: durationIconImageView.trailingAnchor, constant: 4)
            $0.centerY(to: durationIconImageView.centerYAnchor)
        }
        
        timeRangeLabel.layout {
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            $0.centerY(to: durationIconImageView.centerYAnchor)
            $0.bottom(to: containerView.bottomAnchor, constant: -14)
        }
    }
    
    /// Extracts time range from duration string
    /// Expected format: \"09:00-16:00 (7 Hours)\" -> returns \"09:00-16:00 (7 Hours)\"
    /// Or handles other formats gracefully
    private func extractTimeRange(from duration: String) -> String? {
        // If it already contains time format (HH:MM), return as is
        if duration.contains(":") {
            return duration
        }
        
        // For other formats, return nil to use fallback
        return nil
    }
}
