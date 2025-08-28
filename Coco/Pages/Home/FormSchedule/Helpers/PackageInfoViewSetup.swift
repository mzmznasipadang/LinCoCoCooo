//
//  PackageInfoViewSetup.swift
//  Coco
//
//  Created by Claude on 28/08/25.
//

import Foundation
import UIKit

// MARK: - Package Info Components
struct PackageInfoComponents {
    let container: UIView
    let imageView: UIImageView
    let nameLabel: UILabel
    let paxIconImageView: UIImageView
    let paxLabel: UILabel
    let priceLabel: UILabel
    let descriptionLabel: UILabel
    let durationIconImageView: UIImageView
    let durationTitleLabel: UILabel
    let timeRangeLabel: UILabel
}

struct PackageInfoLabels {
    let imageView: UIImageView
    let nameLabel: UILabel
    let paxLabel: UILabel
    let priceLabel: UILabel
    let descriptionLabel: UILabel
    let durationTitleLabel: UILabel
    let timeRangeLabel: UILabel
}

// MARK: - Package Info View Setup
internal class PackageInfoViewSetup {
    
    static func setupPackageInfoSection(components: PackageInfoComponents) {
        components.container.addSubviews([
            components.imageView,
            components.nameLabel,
            components.paxIconImageView,
            components.paxLabel,
            components.priceLabel,
            components.descriptionLabel,
            components.durationIconImageView,
            components.durationTitleLabel,
            components.timeRangeLabel
        ])
        
        // Layout package info components with proper auto layout for dynamic content
        components.imageView.layout {
            $0.leading(to: components.container.leadingAnchor, constant: 16)
            $0.top(to: components.container.topAnchor, constant: 16)
            $0.width(80)   // 1:1 ratio
            $0.height(80)  // 1:1 ratio
        }
        
        components.nameLabel.layout {
            $0.leading(to: components.imageView.trailingAnchor, constant: 16)
            $0.top(to: components.container.topAnchor, constant: 16)
            $0.trailing(to: components.container.trailingAnchor, constant: -16)
        }
        
        components.paxIconImageView.layout {
            $0.leading(to: components.imageView.trailingAnchor, constant: 12)
            $0.top(to: components.nameLabel.bottomAnchor, constant: 6)
            $0.size(14)
        }
        
        components.paxLabel.layout {
            $0.leading(to: components.paxIconImageView.trailingAnchor, constant: 4)
            $0.centerY(to: components.paxIconImageView.centerYAnchor)
            $0.trailing(to: components.container.trailingAnchor, constant: -16)
        }
        
        components.priceLabel.layout {
            $0.leading(to: components.imageView.trailingAnchor, constant: 12)
            $0.top(to: components.paxIconImageView.bottomAnchor, constant: 8)
            $0.trailing(to: components.container.trailingAnchor, constant: -16)
        }
        
        // Position description below the tallest element (image or price area)
        components.descriptionLabel.layout {
            $0.leading(to: components.container.leadingAnchor, constant: 16)
            $0.top(to: components.priceLabel.bottomAnchor, constant: 12) // Position below price to avoid overlap
            $0.trailing(to: components.container.trailingAnchor, constant: -16)
        }
        
        components.durationIconImageView.layout {
            $0.leading(to: components.container.leadingAnchor, constant: 16)
            $0.top(to: components.descriptionLabel.bottomAnchor, constant: 8)
            $0.size(16)
        }
        
        components.durationTitleLabel.layout {
            $0.leading(to: components.durationIconImageView.trailingAnchor, constant: 4)
            $0.centerY(to: components.durationIconImageView.centerYAnchor)
        }
        
        components.timeRangeLabel.layout {
            $0.trailing(to: components.container.trailingAnchor, constant: -16)
            $0.centerY(to: components.durationIconImageView.centerYAnchor)
            $0.bottom(to: components.container.bottomAnchor, constant: -14)
        }
    }
    
    static func configurePackageInfo(
        data: PackageInfoDisplayData,
        labels: PackageInfoLabels
    ) {
        labels.imageView.loadImage(from: URL(string: data.imageUrl))
        labels.nameLabel.text = data.packageName
        labels.paxLabel.text = data.paxRange
        
        // Format price with /person suffix
        let priceText = "\(data.pricePerPax)/person"
        let attributedString = NSMutableAttributedString(string: priceText)
        
        // Style the main price part (bold, black) - smaller font to match Image #2
        let priceRange = NSRange(location: 0, length: data.pricePerPax.count)
        attributedString.addAttribute(.font, value: UIFont.jakartaSans(forTextStyle: .headline, weight: .bold), range: priceRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1), range: priceRange)
        
        // Style the /person suffix (smaller, gray)
        let suffixRange = NSRange(location: data.pricePerPax.count, length: 7) // "/person"
        attributedString.addAttribute(.font, value: UIFont.jakartaSans(forTextStyle: .caption1, weight: .medium), range: suffixRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1), range: suffixRange)
        
        labels.priceLabel.attributedText = attributedString
        
        // Show the actual package description instead of hiding it
        labels.descriptionLabel.text = data.description
        labels.descriptionLabel.isHidden = false
        
        // Set duration title and parse time range from duration
        labels.durationTitleLabel.text = "Duration"
        
        // Parse duration string to extract time range - expecting format like "09:00-16:00 (7 Hours)"
        if let timeRange = extractTimeRange(from: data.duration) {
            labels.timeRangeLabel.text = timeRange
        } else {
            labels.timeRangeLabel.text = data.duration // Fallback to original format
        }
    }
    
    /// Extracts time range from duration string
    /// Expected format: "09:00-16:00 (7 Hours)" -> returns "09:00-16:00 (7 Hours)"
    /// Or handles other formats gracefully
    private static func extractTimeRange(from duration: String) -> String? {
        // If it already contains time format (HH:MM), return as is
        if duration.contains(":") {
            return duration
        }
        
        // For other formats, return nil to use fallback
        return nil
    }
}
