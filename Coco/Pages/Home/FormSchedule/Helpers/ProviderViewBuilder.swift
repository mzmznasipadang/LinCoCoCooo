//
//  ProviderViewBuilder.swift
//  Coco
//
//  Created by Claude on 28/08/25.
//

import Foundation
import UIKit

// MARK: - Provider View Builder
internal class ProviderViewBuilder {
    
    static func createProviderContentView(provider: TripProviderDisplayItem) -> UIView {
        let view = UIView()
        
        let providerImageView = UIImageView()
        providerImageView.contentMode = .scaleAspectFill
        providerImageView.clipsToBounds = true
        providerImageView.layer.cornerRadius = 12 // Matching Figma design
        providerImageView.backgroundColor = Token.grayscale20
        providerImageView.loadImage(from: URL(string: provider.imageUrl))
        
        let providerNameLabel = UILabel(
            font: .jakartaSans(forTextStyle: .headline, weight: .bold),
            textColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1),
            numberOfLines: 1
        )
        providerNameLabel.text = provider.name
        
        let providerDescriptionLabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: UIColor(red: 102/255, green: 112/255, blue: 122/255, alpha: 1),
            numberOfLines: 0
        )
        providerDescriptionLabel.text = provider.description
        providerDescriptionLabel.lineBreakMode = .byWordWrapping
        
        view.addSubviews([providerImageView, providerNameLabel, providerDescriptionLabel])
        
        // Match Figma design dimensions and spacing
        providerImageView.layout {
            $0.leading(to: view.leadingAnchor)
            $0.top(to: view.topAnchor)
            $0.width(65) // From Figma design
            $0.height(64) // From Figma design
        }
        
        providerNameLabel.layout {
            $0.leading(to: providerImageView.trailingAnchor, constant: 8)
            $0.top(to: view.topAnchor, constant: 2)
            $0.trailing(to: view.trailingAnchor)
        }
        
        providerDescriptionLabel.layout {
            $0.leading(to: providerImageView.trailingAnchor, constant: 8)
            $0.top(to: providerNameLabel.bottomAnchor, constant: 4)
            $0.trailing(to: view.trailingAnchor)
            $0.bottom(to: view.bottomAnchor)
        }
        
        // Set content priorities for proper text wrapping
        providerDescriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        providerDescriptionLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        return view
    }
}
