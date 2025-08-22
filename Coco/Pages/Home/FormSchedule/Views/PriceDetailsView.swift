//
//  PriceDetailsView.swift
//  Coco
//
//  Created by Claude on 22/08/25.
//

import Foundation
import UIKit

// MARK: - Price Details Data Model

/// Data model for the price details section
struct PriceDetailsData {
    /// Selected date string (e.g., "Wed, 21 May 2024")
    let selectedDate: String
    
    /// Number of participants
    let participantCount: Int
    
    /// Traveler's name
    let travelerName: String
    
    /// Total price formatted string (e.g., "Rp3,750,000")
    let totalPrice: String
    
    /// Whether all required fields are filled
    var isComplete: Bool {
        return !selectedDate.contains("Select") && !travelerName.isEmpty
    }
    
    /// Whether the form has basic info (date selected, even if name is empty)
    var hasBasicInfo: Bool {
        return !selectedDate.contains("Select")
    }
}

// MARK: - PriceDetailsView

/// Collapsible price details view for the bottom sticky section
/// Shows booking summary with expand/collapse functionality
final class PriceDetailsView: UIView {
    
    // MARK: - Properties
    
    /// Current expanded state
    private var isExpanded = false
    
    /// Callback when book now button is tapped
    var onBookNow: (() -> Void)?
    
    /// Current booking data
    private var bookingData: PriceDetailsData?
    
    // MARK: - UI Components
    
    /// Container view with shadow and rounded corners
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Token.additionalColorsWhite
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    /// Header view that's always visible
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    /// "Price Details" title label
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Price Details"
        label.font = .jakartaSans(forTextStyle: .headline, weight: .semibold)
        label.textColor = Token.grayscale90
        return label
    }()
    
    /// Chevron icon for expand/collapse
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.up")
        imageView.tintColor = Token.grayscale50
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// Total price label in header
    private lazy var headerPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .headline, weight: .bold)
        label.textColor = Token.grayscale90
        label.textAlignment = .right
        return label
    }()
    
    /// Expandable details container
    private lazy var detailsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    /// Details stack view
    private lazy var detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        return stackView
    }()
    
    /// Book Now button
    private lazy var bookNowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Book Now", for: .normal)
        button.titleLabel?.font = .jakartaSans(forTextStyle: .body, weight: .semibold)
        button.backgroundColor = Token.mainColorPrimary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(bookNowTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubviews([headerView, detailsContainer, bookNowButton])
        
        headerView.addSubviews([titleLabel, chevronImageView, headerPriceLabel])
        detailsContainer.addSubview(detailsStackView)
        
        setupConstraints()
        
        // Store reference to height constraint for animation
        detailsHeightConstraint = detailsContainer.heightAnchor.constraint(equalToConstant: 0)
        detailsHeightConstraint.isActive = true
    }
    
    private func setupConstraints() {
        containerView.layout {
            $0.top(to: topAnchor)
            $0.leading(to: leadingAnchor)
            $0.trailing(to: trailingAnchor)
            $0.bottom(to: safeAreaLayoutGuide.bottomAnchor)
        }
        
        headerView.layout {
            $0.top(to: containerView.topAnchor, constant: 12)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            $0.height(44)
        }
        
        titleLabel.layout {
            $0.leading(to: headerView.leadingAnchor)
            $0.centerY(to: headerView.centerYAnchor)
        }
        
        chevronImageView.layout {
            $0.trailing(to: headerView.trailingAnchor)
            $0.centerY(to: headerView.centerYAnchor)
            $0.width(16)
            $0.height(16)
        }
        
        headerPriceLabel.layout {
            $0.trailing(to: chevronImageView.leadingAnchor, constant: -8)
            $0.centerY(to: headerView.centerYAnchor)
        }
        
        detailsContainer.layout {
            $0.top(to: headerView.bottomAnchor, constant: 8)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            // Height constraint will be added in setupView()
        }
        
        detailsStackView.layout {
            $0.top(to: detailsContainer.topAnchor)
            $0.leading(to: detailsContainer.leadingAnchor)
            $0.trailing(to: detailsContainer.trailingAnchor)
            $0.bottom(to: detailsContainer.bottomAnchor)
        }
        
        bookNowButton.layout {
            $0.top(to: detailsContainer.bottomAnchor, constant: 16)
            $0.leading(to: containerView.leadingAnchor, constant: 16)
            $0.trailing(to: containerView.trailingAnchor, constant: -16)
            $0.bottom(to: containerView.bottomAnchor, constant: -12)
            $0.height(52)
        }
    }
    
    /// Height constraint for the details container (used for animations)
    private var detailsHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Configuration
    
    /// Updates the view with new booking data
    func configure(with data: PriceDetailsData) {
        self.bookingData = data
        
        // Update header price
        headerPriceLabel.text = data.totalPrice
        
        // Clear existing details
        detailsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add detail rows only if we have basic info
        if data.hasBasicInfo {
            addDetailRow(title: "Dates", value: data.selectedDate)
            addDetailRow(title: "Pax", value: "\(data.participantCount)")
            if !data.travelerName.isEmpty {
                addDetailRow(title: "Name", value: data.travelerName)
            }
            addDetailRow(title: "Pay during trip", value: data.totalPrice, isTotal: true)
        }
        
        // Make sure we start collapsed if not expanded
        if !isExpanded {
            detailsHeightConstraint.constant = 0
            detailsContainer.isHidden = true
        }
        
        // Update button state - enable if date is selected (basic requirement)
        bookNowButton.isEnabled = data.hasBasicInfo
        bookNowButton.alpha = data.hasBasicInfo ? 1.0 : 0.6
    }
    
    private func addDetailRow(title: String, value: String, isTotal: Bool = false) {
        let containerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = isTotal ? .jakartaSans(forTextStyle: .body, weight: .semibold) : .jakartaSans(forTextStyle: .body, weight: .regular)
        titleLabel.textColor = Token.grayscale90
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = isTotal ? .jakartaSans(forTextStyle: .body, weight: .bold) : .jakartaSans(forTextStyle: .body, weight: .regular)
        valueLabel.textColor = Token.grayscale90
        valueLabel.textAlignment = .right
        
        containerView.addSubviews([titleLabel, valueLabel])
        
        titleLabel.layout {
            $0.leading(to: containerView.leadingAnchor)
            $0.centerY(to: containerView.centerYAnchor)
        }
        
        valueLabel.layout {
            $0.trailing(to: containerView.trailingAnchor)
            $0.centerY(to: containerView.centerYAnchor)
        }
        
        containerView.layout {
            $0.height(24)
        }
        
        detailsStackView.addArrangedSubview(containerView)
    }
    
    // MARK: - Actions
    
    @objc private func headerTapped() {
        guard bookingData?.hasBasicInfo == true else { return }
        
        isExpanded.toggle()
        
        // Calculate target height
        let targetHeight: CGFloat = isExpanded ? calculateExpandedHeight() : 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            // Rotate chevron
            self.chevronImageView.transform = self.isExpanded ? 
                CGAffineTransform(rotationAngle: .pi) : .identity
            
            // Update height constraint
            self.detailsHeightConstraint.constant = targetHeight
            
            // Show/hide details container
            self.detailsContainer.isHidden = !self.isExpanded
            
            // Update layout
            self.layoutIfNeeded()
        })
    }
    
    /// Calculates the height needed for expanded content
    private func calculateExpandedHeight() -> CGFloat {
        guard let data = bookingData else { return 0 }
        
        // Each detail row is 24pt + 12pt spacing, plus some padding
        let rowCount = data.hasBasicInfo ? 4 : 1 // dates, pax, name, total price
        return CGFloat(rowCount * 24 + (rowCount - 1) * 12) // rows + spacing
    }
    
    @objc private func bookNowTapped() {
        onBookNow?()
    }
}