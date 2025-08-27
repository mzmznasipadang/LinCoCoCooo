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
        label.font = .jakartaSans(forTextStyle: .body, weight: .medium)
        label.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)
        return label
    }()
    
    /// Chevron icon for expand/collapse
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.up")
        imageView.tintColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// Total price label in header
    private lazy var headerPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .body, weight: .semibold)
        label.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)
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
        stackView.spacing = 8  // Reduced spacing to match Figma design
        stackView.distribution = .fill
        return stackView
    }()
    
    /// Book Now button
    private lazy var bookNowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Book Now", for: .normal)
        button.titleLabel?.font = .jakartaSans(forTextStyle: .body, weight: .semibold)
        button.backgroundColor = UIColor(red: 26/255, green: 178/255, blue: 229/255, alpha: 1)
        button.setTitleColor(UIColor(red: 254/255, green: 254/255, blue: 254/255, alpha: 1), for: .normal)
        button.layer.cornerRadius = 24
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
            $0.top(to: headerView.bottomAnchor, constant: 16)
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
            $0.height(52)
        }
        
        // Connect containerView bottom to safe area with proper padding (following ActivityDetailView pattern)
        bookNowButton.layout {
            $0.bottom(to: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        }
        
        containerView.layout {
            $0.bottom(to: bottomAnchor)
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
            addDetailRow(title: Localization.Price.dates, value: data.selectedDate)
            addDetailRow(title: Localization.Price.pax, value: "\(data.participantCount)")
            if !data.travelerName.isEmpty {
                addDetailRow(title: Localization.Price.name, value: data.travelerName, shouldAddSeparator: true)
            }
            addDetailRow(title: Localization.Price.payDuringTrip, value: data.totalPrice, isTotal: true)
        }
        
        // Make sure we start collapsed if not expanded
        if !isExpanded {
            detailsHeightConstraint.constant = 0
            detailsContainer.isHidden = true
        }
        
        // Update button state - enable if date is selected (basic requirement)
        print("🔍 PRICEDETAILSVIEW: Configuring button - hasBasicInfo: \(data.hasBasicInfo), selectedDate: '\(data.selectedDate)'")
        bookNowButton.isEnabled = data.hasBasicInfo
        bookNowButton.alpha = data.hasBasicInfo ? 1.0 : 0.6
        print("🔍 PRICEDETAILSVIEW: Button enabled: \(bookNowButton.isEnabled), alpha: \(bookNowButton.alpha)")
    }
    
    private func addDetailRow(title: String, value: String, isTotal: Bool = false, shouldAddSeparator: Bool = false) {
        let containerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        // Use different font weights based on Figma design
        titleLabel.font = isTotal ? .jakartaSans(forTextStyle: .body, weight: .bold) : .jakartaSans(forTextStyle: .body, weight: .medium)
        titleLabel.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        // Use different font weights based on Figma design
        valueLabel.font = isTotal ? .jakartaSans(forTextStyle: .body, weight: .bold) : .jakartaSans(forTextStyle: .body, weight: .semibold)
        valueLabel.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)
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
        
        // Add separator line if needed (for Name row)
        if shouldAddSeparator {
            let separatorLine = UIView()
            separatorLine.backgroundColor = UIColor(red: 227/255, green: 231/255, blue: 236/255, alpha: 1)
            containerView.addSubview(separatorLine)
            
            separatorLine.layout {
                $0.leading(to: containerView.leadingAnchor)
                $0.trailing(to: containerView.trailingAnchor)
                $0.bottom(to: containerView.bottomAnchor)
                $0.height(1)
            }
        }
        
        containerView.layout {
            $0.height(44)  // Increased height for better spacing like Figma
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
            
            // Hide/show header price based on expanded state
            self.headerPriceLabel.alpha = self.isExpanded ? 0.0 : 1.0
            
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
        
        // Each detail row is now 44pt + 8pt spacing between rows
        var rowCount = 3 // dates, pax, total price (always shown)
        if !data.travelerName.isEmpty {
            rowCount += 1 // add name row if present
        }
        
        let rowHeight: CGFloat = 44
        let spacing: CGFloat = 8
        return CGFloat(rowCount) * rowHeight + CGFloat(rowCount - 1) * spacing
    }
    
    @objc private func bookNowTapped() {
        print("🚨 PRICEDETAILSVIEW: Book Now button TAPPED!")
        NSLog("🚨 PRICEDETAILSVIEW: Book Now button TAPPED!")
        onBookNow?()
        print("🚨 PRICEDETAILSVIEW: onBookNow callback called!")
        NSLog("🚨 PRICEDETAILSVIEW: onBookNow callback called!")
    }
}
