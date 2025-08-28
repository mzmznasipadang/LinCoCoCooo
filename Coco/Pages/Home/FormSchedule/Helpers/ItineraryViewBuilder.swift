//
//  ItineraryViewBuilder.swift
//  Coco
//
//  Created by Claude on 28/08/25.
//

import Foundation
import UIKit

// MARK: - Itinerary View Builder
class ItineraryViewBuilder {
    
    static func createItineraryContentView(items: [ItineraryDisplayItem]) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16 // Add spacing between items for better readability
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        for (index, item) in items.enumerated() {
            let itemView = createSimpleItineraryItemView(
                item: item,
                isFirst: index == 0,
                isLast: index == items.count - 1
            )
            stackView.addArrangedSubview(itemView)
        }
        
        containerView.addSubview(stackView)
        stackView.layout {
            $0.top(to: containerView.topAnchor)
            $0.leading(to: containerView.leadingAnchor)
            $0.trailing(to: containerView.trailingAnchor)
            $0.bottom(to: containerView.bottomAnchor)
        }
        
        // Set proper content priorities
        stackView.setContentHuggingPriority(.required, for: .vertical)
        containerView.setContentHuggingPriority(.required, for: .vertical)
        
        return containerView
    }
    
    private static func createSimpleItineraryItemView(item: ItineraryDisplayItem, isFirst: Bool, isLast: Bool) -> UIView {
        let itemView = UIView()
        
        // Timeline dot
        let dotView = UIView()
        dotView.backgroundColor = UIColor(red: 26/255, green: 178/255, blue: 229/255, alpha: 1)
        dotView.layer.cornerRadius = 8
        
        // Timeline line (only show if not last item)
        let lineView = UIView()
        lineView.backgroundColor = UIColor(red: 26/255, green: 178/255, blue: 229/255, alpha: 1)
        lineView.isHidden = isLast
        
        // Time label
        let timeLabel = UILabel()
        timeLabel.font = .jakartaSans(forTextStyle: .footnote, weight: .bold)
        timeLabel.textColor = UIColor(red: 102/255, green: 112/255, blue: 122/255, alpha: 1)
        timeLabel.text = item.time ?? ""
        timeLabel.numberOfLines = 1
        
        // Title label with proper wrapping
        let titleLabel = UILabel()
        titleLabel.font = .jakartaSans(forTextStyle: .footnote, weight: .medium)
        titleLabel.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)
        titleLabel.text = item.title
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        
        itemView.addSubviews([dotView, lineView, timeLabel, titleLabel])
        
        // Layout dot
        dotView.layout {
            $0.leading(to: itemView.leadingAnchor)
            $0.top(to: itemView.topAnchor, constant: 6)
            $0.size(16)
        }
        
        // Layout connecting line
        lineView.layout {
            $0.centerX(to: dotView.centerXAnchor)
            $0.top(to: dotView.bottomAnchor, constant: 4)
            $0.bottom(to: itemView.bottomAnchor)
            $0.width(2)
        }
        
        // Layout time label
        timeLabel.layout {
            $0.leading(to: dotView.trailingAnchor, constant: 16)
            $0.top(to: itemView.topAnchor, constant: 4)
        }
        
        // Layout title label
        titleLabel.layout {
            $0.leading(to: timeLabel.trailingAnchor, constant: 8)
            $0.top(to: itemView.topAnchor, constant: 4)
            $0.trailing(to: itemView.trailingAnchor, constant: -8)
            $0.bottom(to: itemView.bottomAnchor, constant: -4)
        }
        
        // Set priorities for the item view
        itemView.setContentHuggingPriority(.required, for: .vertical)
        
        return itemView
    }
}