//
//  BookingDetailPresentationModels.swift
//  Coco
//
//  Created by Victor Chandra on 20/08/25.
//

import Foundation
import UIKit

// MARK: - Section Types

/// Enum defining the different types of sections in the booking detail screen
/// Each type corresponds to a different cell type and data structure
enum BookingDetailSectionType {
    /// Package information section showing main package details with image, price, description
    case packageInfo
    /// Trip provider section showing host/provider information
    case tripProvider
    /// Itinerary section showing trip schedule and activities in timeline format
    case itinerary
    /// Form inputs section for date and participant selection
    case formInputs
    /// Traveler details section for contact information input
    case travelerDetails
}

// MARK: - Section Model for TableView

/// Model representing a section in the booking detail table view
/// Supports collapsible sections and contains heterogeneous data items
struct BookingDetailSection {
    /// The type of section which determines how it's rendered and what cell type to use
    let type: BookingDetailSectionType
    
    /// Optional title displayed in the section header (nil for sections without headers)
    let title: String?
    
    /// Whether this section can be collapsed/expanded by tapping the header
    let isExpandable: Bool
    
    /// Current expanded state - only relevant if isExpandable is true
    var isExpanded: Bool
    
    /// Array of items to display in this section
    /// Type varies by section: PackageInfoDisplayData, TripProviderDisplayItem, ItineraryDisplayItem, etc.
    let items: [Any]
}

// MARK: - Package Info Card Model (Top section)

/// Display data for the package information section
/// Contains all visual and descriptive information about the selected package
struct PackageInfoDisplayData {
    /// URL for the main package image
    let imageUrl: String
    
    /// Name of the selected package/plan
    let packageName: String
    
    /// Formatted participant range string (e.g., "Min.2 - Max.8")
    let paxRange: String
    
    /// Formatted price per participant (e.g., "Rp500,000")
    let pricePerPax: String
    
    /// Original price before discount (if applicable)
    let originalPrice: String?
    
    /// Whether this package has a discount applied
    let hasDiscount: Bool
    
    /// Detailed description of the package
    let description: String
    
    /// Formatted duration with time range (e.g., "09:00-13:00 (4 Hours)")
    let duration: String
}

// MARK: - Itinerary Timeline Model

/// Display data for individual itinerary items shown in timeline format
/// Contains scheduling and activity information with UI positioning data
struct ItineraryDisplayItem {
    /// Start time for this activity (optional, e.g., "09:00")
    let time: String?
    
    /// Title/name of the activity
    let title: String
    
    /// Detailed description of what happens during this activity
    let description: String?
    
    /// Duration of this specific activity (e.g., "2 hours")
    let duration: String?
    
    // MARK: UI helpers for timeline drawing
    
    /// Whether this is the first item in the timeline (affects line drawing)
    let isFirstItem: Bool
    
    /// Whether this is the last item in the timeline (affects line drawing)
    let isLastItem: Bool
}

// MARK: - Trip Provider Model

/// Display data for trip provider/host information
/// Contains information about who is providing the travel experience
struct TripProviderDisplayItem {
    /// Name of the trip provider or host
    let name: String
    
    /// Bio or description of the provider's background and experience
    let description: String
    
    /// URL for the provider's profile image
    let imageUrl: String
}

// MARK: - Helper Models for Timeline UI

/// Configuration for timeline visual appearance in itinerary section
/// Defines colors, sizes, and styling for the timeline UI elements
struct TimelineConfiguration {
    /// Color for the timeline dots/markers
    let dotColor: UIColor
    
    /// Color for the connecting lines between timeline items
    let lineColor: UIColor
    
    /// Size of the timeline dots in points
    let dotSize: CGFloat
    
    /// Width of the connecting lines in points
    let lineWidth: CGFloat
    
    /// Default configuration using app's primary color scheme
    static var `default`: TimelineConfiguration {
        return TimelineConfiguration(
            dotColor: Token.mainColorPrimary,
            lineColor: Token.mainColorPrimary,
            dotSize: 12.0,
            lineWidth: 2.0
        )
    }
}
