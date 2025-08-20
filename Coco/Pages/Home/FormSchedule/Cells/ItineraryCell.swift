//
//  ItineraryCell.swift
//  Coco
//
//  Created by Victor Chandra on 20/08/25.
//

import Foundation
import UIKit

final class ItineraryCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: ItineraryDisplayItem) {
        timeLabel.text = item.time
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        descriptionLabel.isHidden = item.description == nil
        
        // Configure timeline
        topLineView.isHidden = item.isFirstItem
        bottomLineView.isHidden = item.isLastItem
    }
    
    // Timeline UI Components
    private lazy var dotView: UIView = {
        let view = UIView()
        view.backgroundColor = Token.mainColorPrimary
        view.layer.cornerRadius = 6
        return view
    }()
    
    private lazy var topLineView: UIView = {
        let view = UIView()
        view.backgroundColor = Token.mainColorPrimary
        return view
    }()
    
    private lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = Token.mainColorPrimary
        return view
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel(
            font: .jakartaSans(forTextStyle: .caption1, weight: .medium),
            textColor: Token.grayscale50,
            numberOfLines: 1
        )
        label.textAlignment = .left  // Ensure left alignment
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(
            font: .jakartaSans(forTextStyle: .callout, weight: .semibold),
            textColor: Token.grayscale90,
            numberOfLines: 0
        )
        label.textAlignment = .left  // Ensure left alignment
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
            textColor: Token.grayscale60,
            numberOfLines: 0
        )
        label.textAlignment = .left  // Ensure left alignment
        return label
    }()
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = Token.additionalColorsWhite
        
        contentView.addSubviews([
            topLineView,
            bottomLineView,
            dotView,
            timeLabel,
            titleLabel,
            descriptionLabel
        ])
        
        // Timeline layout - dot on the left
        dotView.layout {
            $0.leading(to: contentView.leadingAnchor, constant: 24)  // Adjusted from 32
            $0.top(to: contentView.topAnchor, constant: 20)
            $0.size(12)
        }
        
        topLineView.layout {
            $0.centerX(to: dotView.centerXAnchor)
            $0.bottom(to: dotView.topAnchor)
            $0.top(to: contentView.topAnchor)
            $0.width(2)
        }
        
        bottomLineView.layout {
            $0.centerX(to: dotView.centerXAnchor)
            $0.top(to: dotView.bottomAnchor)
            $0.bottom(to: contentView.bottomAnchor)
            $0.width(2)
        }
        
        // Time label - fixed width, left of content
        timeLabel.layout {
            $0.leading(to: dotView.trailingAnchor, constant: 16)
            $0.top(to: contentView.topAnchor, constant: 20)
            $0.width(60)  // Fixed width for time
        }
        
        // Title label - main content area
        titleLabel.layout {
            $0.leading(to: timeLabel.trailingAnchor, constant: 12)  // Reduced spacing
            $0.trailing(to: contentView.trailingAnchor, constant: -16)
            $0.top(to: contentView.topAnchor, constant: 20)
        }
        
        // Description label - below title
        descriptionLabel.layout {
            $0.leading(to: titleLabel.leadingAnchor)
            $0.top(to: titleLabel.bottomAnchor, constant: 4)
            $0.trailing(to: contentView.trailingAnchor, constant: -16)
            $0.bottom(to: contentView.bottomAnchor, constant: -16)
        }
    }
}
