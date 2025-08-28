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
        case .tripProvider:
            configureTripProvider(items: items)
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
    
    private func configureTripProvider(items: [Any]) {
        guard let providerData = items.first as? TripProviderDisplayItem else { return }
        
        let providerView = createTripProviderView(provider: providerData)
        stackView.addArrangedSubview(providerView)
    }
    
    private func createTripProviderView(provider: TripProviderDisplayItem) -> UIView {
        let view = UIView()
        
        let providerImageView = UIImageView()
        providerImageView.contentMode = .scaleAspectFill
        providerImageView.clipsToBounds = true
        providerImageView.layer.cornerRadius = 24
        providerImageView.backgroundColor = Token.grayscale20
        providerImageView.loadImage(from: URL(string: provider.imageUrl))
        
        let providerNameLabel = UILabel(
            font: .jakartaSans(forTextStyle: .headline, weight: .semibold),
            textColor: Token.grayscale90,
            numberOfLines: 1
        )
        providerNameLabel.text = provider.name
        
        let providerDescriptionLabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
            textColor: Token.grayscale70,
            numberOfLines: 0
        )
        providerDescriptionLabel.text = provider.description
        
        view.addSubviews([providerImageView, providerNameLabel, providerDescriptionLabel])
        
        providerImageView.layout {
            $0.leading(to: view.leadingAnchor)
            $0.top(to: view.topAnchor)
            $0.size(48)
        }
        
        providerNameLabel.layout {
            $0.leading(to: providerImageView.trailingAnchor, constant: 12)
            $0.top(to: view.topAnchor)
            $0.trailing(to: view.trailingAnchor)
        }
        
        providerDescriptionLabel.layout {
            $0.leading(to: providerImageView.trailingAnchor, constant: 12)
            $0.top(to: providerNameLabel.bottomAnchor, constant: 8)
            $0.trailing(to: view.trailingAnchor)
            $0.bottom(to: view.bottomAnchor)
        }
        
        return view
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
            $0.top(to: containerView.topAnchor, constant: 16)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            $0.bottom(to: containerView.bottomAnchor, constant: -16)
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
            $0.leading(to: view.leadingAnchor, constant: 16)
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
    
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = Token.grayscale20
        separator.layout {
            $0.height(1)
        }
        return separator
    }
}
