//
//  SectionContainerCell.swift
//  Coco
//
//  Created by Victor Chandra on 20/08/25.
//

import Foundation
import UIKit

final class SectionContainerCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with items: [Any], sectionType: BookingDetailSectionType) {
        // Clear previous content
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        switch sectionType {
        case .itinerary:
            configureItinerary(items: items)
        case .facilities:
            configureFacilities(items: items)
        case .termsAndConditions:
            configureTerms(items: items)
        default:
            break
        }
    }
    
    private func configureItinerary(items: [Any]) {
        guard let itineraryItems = items as? [ItineraryDisplayItem] else { return }
        
        for (index, item) in itineraryItems.enumerated() {
            let itemView = createItineraryItemView(
                item: item,
                isFirst: index == 0,
                isLast: index == itineraryItems.count - 1
            )
            stackView.addArrangedSubview(itemView)
        }
    }
    
    private func configureFacilities(items: [Any]) {
        guard let facilityItems = items as? [FacilityDisplayItem] else { return }
        
        for item in facilityItems {
            let itemView = createFacilityItemView(item: item)
            stackView.addArrangedSubview(itemView)
            
            // Add separator except for last item
            if item != facilityItems.last {
                let separator = createSeparator()
                stackView.addArrangedSubview(separator)
            }
        }
    }
    
    private func configureTerms(items: [Any]) {
        guard let termsItems = items as? [TermsDisplayItem] else { return }
        
        for item in termsItems {
            let itemView = createTermsItemView(item: item)
            stackView.addArrangedSubview(itemView)
            
            // Add separator except for last item
            if item != termsItems.last {
                let separator = createSeparator()
                stackView.addArrangedSubview(separator)
            }
        }
    }
    
    // UI Components
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
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        
        containerView.layout {
            $0.top(to: contentView.topAnchor, constant: 8)
            $0.leading(to: contentView.leadingAnchor, constant: 16)
            $0.trailing(to: contentView.trailingAnchor, constant: -16)
            $0.bottom(to: contentView.bottomAnchor, constant: -8)
        }
        
        stackView.layout {
            $0.edges(to: containerView)
        }
    }
    
    // Helper methods to create item views
    private func createItineraryItemView(item: ItineraryDisplayItem, isFirst: Bool, isLast: Bool) -> UIView {
        let view = UIView()
        
        // Create timeline and content
        let dotView = UIView()
        dotView.backgroundColor = Token.mainColorPrimary
        dotView.layer.cornerRadius = 6
        
        let topLine = UIView()
        topLine.backgroundColor = Token.mainColorPrimary
        topLine.isHidden = isFirst
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = Token.mainColorPrimary
        bottomLine.isHidden = isLast
        
        let timeLabel = UILabel(
            font: .jakartaSans(forTextStyle: .caption1, weight: .medium),
            textColor: Token.grayscale50,
            numberOfLines: 1
        )
        timeLabel.text = item.time
        
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .callout, weight: .semibold),
            textColor: Token.grayscale90,
            numberOfLines: 0
        )
        titleLabel.text = item.title
        
        let descLabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
            textColor: Token.grayscale60,
            numberOfLines: 0
        )
        descLabel.text = item.description
        
        view.addSubviews([dotView, topLine, bottomLine, timeLabel, titleLabel, descLabel])
        
        // Layout
        dotView.layout {
            $0.leading(to: view.leadingAnchor, constant: 32)
            $0.top(to: view.topAnchor, constant: 20)
            $0.size(12)
        }
        
        topLine.layout {
            $0.centerX(to: dotView.centerXAnchor)
            $0.bottom(to: dotView.topAnchor)
            $0.top(to: view.topAnchor)
            $0.width(2)
        }
        
        bottomLine.layout {
            $0.centerX(to: dotView.centerXAnchor)
            $0.top(to: dotView.bottomAnchor)
            $0.bottom(to: view.bottomAnchor)
            $0.width(2)
        }
        
        timeLabel.layout {
            $0.leading(to: dotView.trailingAnchor, constant: 16)
            $0.centerY(to: dotView.centerYAnchor)
        }
        
        titleLabel.layout {
            $0.leading(to: timeLabel.trailingAnchor, constant: 16)
            $0.trailing(to: view.trailingAnchor, constant: -16)
            $0.centerY(to: dotView.centerYAnchor)
        }
        
        if item.description != nil {
            descLabel.layout {
                $0.leading(to: titleLabel.leadingAnchor)
                $0.top(to: titleLabel.bottomAnchor, constant: 4)
                $0.trailing(to: view.trailingAnchor, constant: -16)
                $0.bottom(to: view.bottomAnchor, constant: -16)
            }
        } else {
            titleLabel.layout {
                $0.bottom(to: view.bottomAnchor, constant: -16)
            }
        }
        
        return view
    }
    
    private func createFacilityItemView(item: FacilityDisplayItem) -> UIView {
        let view = UIView()
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: item.iconName)
        iconImageView.tintColor = item.isIncluded ? Token.alertsSuccess : Token.grayscale40
        iconImageView.contentMode = .scaleAspectFit
        
        let nameLabel = UILabel(
            font: .jakartaSans(forTextStyle: .callout, weight: .medium),
            textColor: item.isIncluded ? Token.grayscale90 : Token.grayscale50,
            numberOfLines: 0
        )
        nameLabel.text = item.name
        
        let statusLabel = UILabel(
            font: .jakartaSans(forTextStyle: .caption2, weight: .medium),
            textColor: item.isIncluded ? Token.alertsSuccess : Token.grayscale50,
            numberOfLines: 1
        )
        statusLabel.text = item.isIncluded ? "Included" : "Not Included"
        
        view.addSubviews([iconImageView, nameLabel, statusLabel])
        
        iconImageView.layout {
            $0.leading(to: view.leadingAnchor, constant: 16)
            $0.centerY(to: view.centerYAnchor)
            $0.size(24)
        }
        
        nameLabel.layout {
            $0.leading(to: iconImageView.trailingAnchor, constant: 12)
            $0.centerY(to: view.centerYAnchor)
            $0.trailing(to: statusLabel.leadingAnchor, constant: -8)
        }
        
        statusLabel.layout {
            $0.trailing(to: view.trailingAnchor, constant: -16)
            $0.centerY(to: view.centerYAnchor)
        }
        
        view.layout {
            $0.height(44)
        }
        
        return view
    }
    
    private func createTermsItemView(item: TermsDisplayItem) -> UIView {
        let view = UIView()
        
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .callout, weight: .semibold),
            textColor: item.isImportant ? Token.alertsSuccess : Token.grayscale90,
            numberOfLines: 0
        )
        titleLabel.text = item.title
        
        let contentLabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
            textColor: Token.grayscale70,
            numberOfLines: 0
        )
        contentLabel.text = item.content
        
        view.addSubviews([titleLabel, contentLabel])
        
        titleLabel.layout {
            $0.top(to: view.topAnchor, constant: 12)
            $0.leading(to: view.leadingAnchor, constant: 16)
            $0.trailing(to: view.trailingAnchor, constant: -16)
        }
        
        contentLabel.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 8)
            $0.leading(to: view.leadingAnchor, constant: 16)
            $0.trailing(to: view.trailingAnchor, constant: -16)
            $0.bottom(to: view.bottomAnchor, constant: -12)
        }
        
        return view
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = Token.grayscale20
        separator.layout {
            $0.height(1)
        }
        return separator
    }
}
