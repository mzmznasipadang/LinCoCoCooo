//
//  UnifiedBookingDetailCell.swift
//  Coco
//
//  Created by Claude on 27/08/25.
//

import Foundation
import UIKit

// MARK: - Dashed Line Helper View
class DashedLineView: UIView {
    var dashColor: UIColor = .lightGray
    var dashLength: CGFloat = 4
    var gapLength: CGFloat = 4
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupDashedLine()
    }
    
    private func setupDashedLine() {
        layer.sublayers?.removeAll()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = dashColor.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [NSNumber(value: dashLength), NSNumber(value: gapLength)]
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: bounds.height / 2))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 2))
        shapeLayer.path = path
        
        layer.addSublayer(shapeLayer)
    }
}

// MARK: - Unified Booking Detail Cell
/// Single card containing Package Info, Trip Provider, and Itinerary sections
final class UnifiedBookingDetailCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    /// Configures the unified cell with package info, provider data, and itinerary
    func configure(packageData: PackageInfoDisplayData,
                   providerData: TripProviderDisplayItem?,
                   itineraryData: [ItineraryDisplayItem],
                   isProviderExpanded: Bool,
                   isItineraryExpanded: Bool) {
        
        // Configure package info section
        configurePackageInfo(data: packageData)
        
        // Configure trip provider section
        configureTripProvider(data: providerData, isExpanded: isProviderExpanded)
        
        // Configure itinerary section
        configureItinerary(data: itineraryData, isExpanded: isItineraryExpanded)
    }
    
    // MARK: - Callbacks for section toggles
    var onTripProviderTapped: (() -> Void)?
    var onItineraryTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    /// Main card container with shadow and rounded corners
    private lazy var cardContainer: UIView = {
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
    
    /// Main vertical stack view for all content
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Package Info Components
    
    private lazy var packageInfoContainer: UIView = UIView()
    
    private lazy var packageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8  // Slightly smaller corner radius to match design
        imageView.backgroundColor = Token.grayscale20
        return imageView
    }()
    
    private lazy var packageNameLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .title3, weight: .bold),
        textColor: UIColor(red: 23/255, green: 23/255, blue: 37/255, alpha: 1),
        numberOfLines: 2  // Allow for longer package names
    )
    
    private lazy var paxIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var paxLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .caption1, weight: .medium),
        textColor: UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1),
        numberOfLines: 1
    )
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
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
    
    // MARK: - Separator Components
    
    private lazy var providerSeparator: UIView = createDashedSeparator()
    private lazy var itinerarySeparator: UIView = createDashedSeparator()
    
    // MARK: - Trip Provider Components
    
    private lazy var providerHeaderButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(providerHeaderTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var providerTitleLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .headline, weight: .bold),
        textColor: UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1),
        numberOfLines: 1
    )
    
    private lazy var providerChevronView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.tintColor = UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var providerContentContainer: UIView = UIView()
    
    // MARK: - Itinerary Components
    
    private lazy var itineraryHeaderButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(itineraryHeaderTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var itineraryTitleLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .headline, weight: .bold),
        textColor: UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1),
        numberOfLines: 1
    )
    
    private lazy var itineraryChevronView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.tintColor = UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var itineraryContentContainer: UIView = UIView()
    
    // MARK: - Setup
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Set initial text values
        providerTitleLabel.text = "Trip Provider"
        itineraryTitleLabel.text = "Itinerary"
        
        // Add main card container
        contentView.addSubview(cardContainer)
        cardContainer.addSubview(mainStackView)
        
        // Setup card layout
        cardContainer.layout {
            $0.top(to: contentView.topAnchor, constant: 16)
            $0.leading(to: contentView.leadingAnchor, constant: 24)
            $0.trailing(to: contentView.trailingAnchor, constant: -24)
            $0.bottom(to: contentView.bottomAnchor, constant: -8)
        }
        
        mainStackView.layout {
            $0.top(to: cardContainer.topAnchor)
            $0.leading(to: cardContainer.leadingAnchor)
            $0.trailing(to: cardContainer.trailingAnchor)
            $0.bottom(to: cardContainer.bottomAnchor)
        }
        
        // Setup package info section
        setupPackageInfoSection()
        
        // Setup provider section
        setupProviderSection()
        
        // Setup itinerary section
        setupItinerarySection()
        
        // Add sections to main stack
        mainStackView.addArrangedSubview(packageInfoContainer)
        mainStackView.addArrangedSubview(providerSeparator)
        mainStackView.addArrangedSubview(providerHeaderButton)
        mainStackView.addArrangedSubview(providerContentContainer)
        mainStackView.addArrangedSubview(itinerarySeparator)
        mainStackView.addArrangedSubview(itineraryHeaderButton)
        mainStackView.addArrangedSubview(itineraryContentContainer)
    }
    
    private func setupPackageInfoSection() {
        packageInfoContainer.addSubviews([
            packageImageView,
            packageNameLabel,
            paxIconImageView,
            paxLabel,
            priceLabel,
            descriptionLabel,
            durationIconImageView,
            durationTitleLabel,
            timeRangeLabel
        ])
        
        // Layout package info components to match Figma design
        packageImageView.layout {
            $0.leading(to: packageInfoContainer.leadingAnchor, constant: 16)
            $0.top(to: packageInfoContainer.topAnchor, constant: 16)
            $0.width(80)   // 1:1 ratio
            $0.height(80)  // 1:1 ratio
        }
        
        packageNameLabel.layout {
            $0.leading(to: packageImageView.trailingAnchor, constant: 12)
            $0.top(to: packageInfoContainer.topAnchor, constant: 16)
            $0.trailing(to: packageInfoContainer.trailingAnchor, constant: -16)
        }
        
        paxIconImageView.layout {
            $0.leading(to: packageImageView.trailingAnchor, constant: 12)
            $0.top(to: packageNameLabel.bottomAnchor, constant: 6)
            $0.size(14)  // Increased by 2pt
        }
        
        paxLabel.layout {
            $0.leading(to: paxIconImageView.trailingAnchor, constant: 4)
            $0.centerY(to: paxIconImageView.centerYAnchor)
            $0.trailing(to: packageInfoContainer.trailingAnchor, constant: -16)
        }
        
        priceLabel.layout {
            $0.leading(to: packageImageView.trailingAnchor, constant: 12)
            $0.top(to: paxIconImageView.bottomAnchor, constant: 8)  // Reduced spacing
            $0.trailing(to: packageInfoContainer.trailingAnchor, constant: -16)
        }
        
        descriptionLabel.layout {
            $0.leading(to: packageInfoContainer.leadingAnchor, constant: 16)
            $0.top(to: packageImageView.bottomAnchor, constant: 8)  // Reduced spacing
            $0.trailing(to: packageInfoContainer.trailingAnchor, constant: -16)
        }
        
        durationIconImageView.layout {
            $0.leading(to: packageInfoContainer.leadingAnchor, constant: 16)
            $0.top(to: descriptionLabel.bottomAnchor, constant: 8)  // Reduced spacing
            $0.size(16)
        }
        
        durationTitleLabel.layout {
            $0.leading(to: durationIconImageView.trailingAnchor, constant: 6)
            $0.centerY(to: durationIconImageView.centerYAnchor)
        }
        
        timeRangeLabel.layout {
            $0.trailing(to: packageInfoContainer.trailingAnchor, constant: -16)
            $0.centerY(to: durationIconImageView.centerYAnchor)
            $0.bottom(to: packageInfoContainer.bottomAnchor, constant: -16)
        }
    }
    
    private func setupProviderSection() {
        providerHeaderButton.addSubviews([providerTitleLabel, providerChevronView])
        
        providerTitleLabel.layout {
            $0.leading(to: providerHeaderButton.leadingAnchor, constant: 24)
            $0.centerY(to: providerHeaderButton.centerYAnchor)
        }
        
        providerChevronView.layout {
            $0.trailing(to: providerHeaderButton.trailingAnchor, constant: -24)
            $0.centerY(to: providerHeaderButton.centerYAnchor)
            $0.size(20)
        }
        
        providerHeaderButton.layout {
            $0.height(56)
        }
        
        // Provider content will be added dynamically
        providerContentContainer.isHidden = true
    }
    
    private func setupItinerarySection() {
        itineraryHeaderButton.addSubviews([itineraryTitleLabel, itineraryChevronView])
        
        itineraryTitleLabel.layout {
            $0.leading(to: itineraryHeaderButton.leadingAnchor, constant: 24)
            $0.centerY(to: itineraryHeaderButton.centerYAnchor)
        }
        
        itineraryChevronView.layout {
            $0.trailing(to: itineraryHeaderButton.trailingAnchor, constant: -24)
            $0.centerY(to: itineraryHeaderButton.centerYAnchor)
            $0.size(20)
        }
        
        itineraryHeaderButton.layout {
            $0.height(56)
        }
        
        // Itinerary content will be added dynamically
        itineraryContentContainer.isHidden = true
    }
    
    // MARK: - Dashed Separator
    
    private func createDashedSeparator() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        // Create dashed line view that will be styled with CAShapeLayer
        let dashedLineView = DashedLineView()
        dashedLineView.dashColor = UIColor(red: 227/255, green: 231/255, blue: 236/255, alpha: 1)
        dashedLineView.dashLength = 4
        dashedLineView.gapLength = 4
        
        container.addSubview(dashedLineView)
        dashedLineView.layout {
            $0.leading(to: container.leadingAnchor, constant: 24)
            $0.trailing(to: container.trailingAnchor, constant: -24)
            $0.centerY(to: container.centerYAnchor)
            $0.height(1)
        }
        
        container.layout {
            $0.height(1)
        }
        
        return container
    }
    
    // MARK: - Configuration Methods
    
    private func configurePackageInfo(data: PackageInfoDisplayData) {
        packageImageView.loadImage(from: URL(string: data.imageUrl))
        packageNameLabel.text = data.packageName
        paxLabel.text = data.paxRange
        
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
        
        priceLabel.attributedText = attributedString
        
        // Show the actual package description instead of hiding it
        descriptionLabel.text = data.description
        descriptionLabel.isHidden = false
        
        // Set duration title and parse time range from duration
        durationTitleLabel.text = "Duration"
        
        // Parse duration string to extract time range - expecting format like "09:00-16:00 (7 Hours)"
        if let timeRange = extractTimeRange(from: data.duration) {
            timeRangeLabel.text = timeRange
        } else {
            timeRangeLabel.text = data.duration // Fallback to original format
        }
    }
    
    private func configureTripProvider(data: TripProviderDisplayItem?, isExpanded: Bool) {
        providerContentContainer.isHidden = !isExpanded
        rotateChevron(chevron: providerChevronView, isExpanded: isExpanded)
        
        // Clear existing content
        providerContentContainer.subviews.forEach { $0.removeFromSuperview() }
        
        guard let providerData = data else { return }
        
        // Create provider content view
        let contentView = createProviderContentView(provider: providerData)
        providerContentContainer.addSubview(contentView)
        contentView.layout {
            $0.top(to: providerContentContainer.topAnchor, constant: 16)
            $0.leading(to: providerContentContainer.leadingAnchor, constant: 24)
            $0.trailing(to: providerContentContainer.trailingAnchor, constant: -24)
            $0.bottom(to: providerContentContainer.bottomAnchor, constant: -16)
        }
    }
    
    private func configureItinerary(data: [ItineraryDisplayItem], isExpanded: Bool) {
        itineraryContentContainer.isHidden = !isExpanded
        rotateChevron(chevron: itineraryChevronView, isExpanded: isExpanded)
        
        // Clear existing content
        itineraryContentContainer.subviews.forEach { $0.removeFromSuperview() }
        
        guard !data.isEmpty && isExpanded else { return }
        
        // Create itinerary content view
        let contentView = createItineraryContentView(items: data)
        itineraryContentContainer.addSubview(contentView)
        contentView.layout {
            $0.top(to: itineraryContentContainer.topAnchor, constant: 8)
            $0.leading(to: itineraryContentContainer.leadingAnchor)
            $0.trailing(to: itineraryContentContainer.trailingAnchor)
            $0.bottom(to: itineraryContentContainer.bottomAnchor, constant: -8)
        }
    }
    
    // MARK: - Content Creation Helpers
    
    private func createProviderContentView(provider: TripProviderDisplayItem) -> UIView {
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
        
        return view
    }
    
    private func createItineraryContentView(items: [ItineraryDisplayItem]) -> UIView {
        let containerView = UIView()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        for (index, item) in items.enumerated() {
            let itemView = createItineraryItemView(
                item: item,
                isFirst: index == 0,
                isLast: index == items.count - 1
            )
            stackView.addArrangedSubview(itemView)
        }
        
        containerView.addSubview(stackView)
        stackView.layout {
            $0.edges(to: containerView)
        }
        
        return containerView
    }
    
    private func createItineraryItemView(item: ItineraryDisplayItem, isFirst: Bool, isLast: Bool) -> UIView {
        let view = UIView()
        
        // Create timeline components matching Figma design
        let dotView = UIView()
        dotView.backgroundColor = UIColor(red: 26/255, green: 178/255, blue: 229/255, alpha: 1)
        dotView.layer.cornerRadius = 8 // 16px diameter = 8px radius
        
        let topLine = UIView()
        topLine.backgroundColor = UIColor(red: 26/255, green: 178/255, blue: 229/255, alpha: 1)
        topLine.isHidden = isFirst
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(red: 26/255, green: 178/255, blue: 229/255, alpha: 1)
        bottomLine.isHidden = isLast
        
        // Create composite label for time and title (matching Figma)
        let compositeLabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1),
            numberOfLines: 0
        )
        
        // Format the text like in Figma: "9:00 - Gather at Waisai Harbor"
        let timeText = item.time ?? ""
        let titleText = item.title
        let fullText = "\(timeText) - \(titleText)"
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Style the time part (bold, gray)
        let timeRange = NSRange(location: 0, length: timeText.count)
        attributedString.addAttribute(.font, value: UIFont.jakartaSans(forTextStyle: .footnote, weight: .bold), range: timeRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 102/255, green: 112/255, blue: 122/255, alpha: 1), range: timeRange)
        
        // Style the " - " separator and title (regular, black)
        let separatorAndTitleRange = NSRange(location: timeText.count, length: fullText.count - timeText.count)
        attributedString.addAttribute(.font, value: UIFont.jakartaSans(forTextStyle: .footnote, weight: .medium), range: separatorAndTitleRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1), range: separatorAndTitleRange)
        
        // Style just the " - " part to be gray
        let dashRange = NSRange(location: timeText.count, length: 3) // " - "
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1), range: dashRange)
        
        compositeLabel.attributedText = attributedString
        
        view.addSubviews([dotView, topLine, bottomLine, compositeLabel])
        
        // Layout timeline components matching Figma
        dotView.layout {
            $0.leading(to: view.leadingAnchor)
            $0.top(to: view.topAnchor, constant: 6)
            $0.size(16)
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
        
        compositeLabel.layout {
            $0.leading(to: dotView.trailingAnchor, constant: 16)
            $0.top(to: view.topAnchor, constant: 4)
            $0.trailing(to: view.trailingAnchor)
            $0.bottom(to: view.bottomAnchor, constant: -4)
        }
        
        return view
    }
    
    // MARK: - Helper Methods
    
    private func rotateChevron(chevron: UIImageView, isExpanded: Bool) {
        let rotationAngle = isExpanded ? CGFloat.pi : 0
        UIView.animate(withDuration: 0.3) {
            chevron.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }
    
    // MARK: - Actions
    
    @objc private func providerHeaderTapped() {
        onTripProviderTapped?()
    }
    
    @objc private func itineraryHeaderTapped() {
        onItineraryTapped?()
    }
    
    /// Extracts time range from duration string
    /// Expected format: "09:00-16:00 (7 Hours)" -> returns "09:00-16:00 (7 Hours)"
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
