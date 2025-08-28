//
//  UnifiedBookingDetailCell.swift
//  Coco
//
//  Created by Claude on 27/08/25.
//

import Foundation
import UIKit

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
        let packageLabels = PackageInfoLabels(
            imageView: packageImageView,
            nameLabel: packageNameLabel,
            paxLabel: paxLabel,
            priceLabel: priceLabel,
            descriptionLabel: descriptionLabel,
            durationTitleLabel: durationTitleLabel,
            timeRangeLabel: timeRangeLabel
        )
        PackageInfoViewSetup.configurePackageInfo(
            data: packageData,
            labels: packageLabels
        )
        
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
    
    private lazy var providerSeparator: UIView = SectionSetupHelper.createDashedSeparator()
    private lazy var itinerarySeparator: UIView = SectionSetupHelper.createDashedSeparator()
    
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
        
        // Setup card layout with proper content hugging
        cardContainer.layout {
            $0.top(to: contentView.topAnchor, constant: 16)
            $0.leading(to: contentView.leadingAnchor, constant: 24)
            $0.trailing(to: contentView.trailingAnchor, constant: -24)
            $0.bottom(to: contentView.bottomAnchor, constant: -8)
        }
        
        // Ensure the stack view stays within the card container boundaries
        mainStackView.layout {
            $0.top(to: cardContainer.topAnchor)
            $0.leading(to: cardContainer.leadingAnchor)
            $0.trailing(to: cardContainer.trailingAnchor)
            $0.bottom(to: cardContainer.bottomAnchor)
        }
        
        // Set content compression resistance to prevent overflow and allow proper expansion
        mainStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        mainStackView.setContentHuggingPriority(.required, for: .vertical)
        
        // Allow horizontal content to compress if needed but maintain proper layout
        mainStackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        // Ensure card container can expand as needed
        cardContainer.setContentCompressionResistancePriority(.required, for: .vertical)
        cardContainer.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        // Setup package info section
        let packageComponents = PackageInfoComponents(
            container: packageInfoContainer,
            imageView: packageImageView,
            nameLabel: packageNameLabel,
            paxIconImageView: paxIconImageView,
            paxLabel: paxLabel,
            priceLabel: priceLabel,
            descriptionLabel: descriptionLabel,
            durationIconImageView: durationIconImageView,
            durationTitleLabel: durationTitleLabel,
            timeRangeLabel: timeRangeLabel
        )
        PackageInfoViewSetup.setupPackageInfoSection(components: packageComponents)
        
        // Setup provider section
        SectionSetupHelper.setupProviderSection(
            headerButton: providerHeaderButton,
            titleLabel: providerTitleLabel,
            chevronView: providerChevronView,
            contentContainer: providerContentContainer
        )
        
        // Setup itinerary section
        SectionSetupHelper.setupItinerarySection(
            headerButton: itineraryHeaderButton,
            titleLabel: itineraryTitleLabel,
            chevronView: itineraryChevronView,
            contentContainer: itineraryContentContainer
        )
        
        // Add sections to main stack
        mainStackView.addArrangedSubview(packageInfoContainer)
        mainStackView.addArrangedSubview(providerSeparator)
        mainStackView.addArrangedSubview(providerHeaderButton)
        mainStackView.addArrangedSubview(providerContentContainer)
        mainStackView.addArrangedSubview(itinerarySeparator)
        mainStackView.addArrangedSubview(itineraryHeaderButton)
        mainStackView.addArrangedSubview(itineraryContentContainer)
    }
    
    // MARK: - Configuration Methods
    
    private func configureTripProvider(data: TripProviderDisplayItem?, isExpanded: Bool) {
        providerContentContainer.isHidden = !isExpanded
        SectionSetupHelper.rotateChevron(chevron: providerChevronView, isExpanded: isExpanded)
        
        // Clear existing content
        providerContentContainer.subviews.forEach { $0.removeFromSuperview() }
        
        guard let providerData = data else { return }
        
        // Create provider content view
        let contentView = ProviderViewBuilder.createProviderContentView(provider: providerData)
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
        SectionSetupHelper.rotateChevron(chevron: itineraryChevronView, isExpanded: isExpanded)
        
        // Clear existing content
        itineraryContentContainer.subviews.forEach { $0.removeFromSuperview() }
        
        guard !data.isEmpty && isExpanded else { return }
        
        // Create itinerary content view
        let contentView = ItineraryViewBuilder.createItineraryContentView(items: data)
        itineraryContentContainer.addSubview(contentView)
        contentView.layout {
            $0.top(to: itineraryContentContainer.topAnchor, constant: 16)
            $0.leading(to: itineraryContentContainer.leadingAnchor, constant: 24)
            $0.trailing(to: itineraryContentContainer.trailingAnchor, constant: -24)
            $0.bottom(to: itineraryContentContainer.bottomAnchor, constant: -16)
        }
    }
    
    // MARK: - Helper Methods
    
    // MARK: - Actions
    
    @objc private func providerHeaderTapped() {
        onTripProviderTapped?()
    }
    
    @objc private func itineraryHeaderTapped() {
        onItineraryTapped?()
    }
    
}
