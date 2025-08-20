//
//  BookingDetailPresentationModels.swift
//  Coco
//
//  Created by Victor Chandra on 20/08/25.
//

import Foundation
import UIKit

// MARK: - Section Types
enum BookingDetailSectionType {
    case packageInfo
    case itinerary
    case facilities
    case termsAndConditions
}

// MARK: - Section Model for TableView
struct BookingDetailSection {
    let type: BookingDetailSectionType
    let title: String?
    let isExpandable: Bool
    var isExpanded: Bool
    let items: [Any] // Can hold different types per section
}

// MARK: - Package Info Card Model (Top section)
struct PackageInfoDisplayData {
    let imageUrl: String
    let packageName: String
    let paxRange: String
    let pricePerPax: String
    let originalPrice: String? // For strikethrough price if discounted
    let hasDiscount: Bool
}

// MARK: - Itinerary Timeline Model
struct ItineraryDisplayItem {
    let time: String?
    let title: String
    let description: String?
    let duration: String? // e.g., "2 hours"
    
    // UI helpers for timeline drawing
    let isFirstItem: Bool
    let isLastItem: Bool
}

// MARK: - Facility Model
struct FacilityDisplayItem : Equatable {
    let iconName: String // SF Symbol name or asset name
    let name: String
    let isIncluded: Bool
    let description: String?
}

// MARK: - Terms & Conditions Model
struct TermsDisplayItem : Equatable {
    let title: String
    let content: String
    let bulletPoints: [String]? // If terms have bullet points
    let isImportant: Bool // To highlight important terms
}

// MARK: - Helper Models for Timeline UI
struct TimelineConfiguration {
    let dotColor: UIColor
    let lineColor: UIColor
    let dotSize: CGFloat
    let lineWidth: CGFloat
    
    static var `default`: TimelineConfiguration {
        return TimelineConfiguration(
            dotColor: Token.mainColorPrimary,
            lineColor: Token.mainColorPrimary,
            dotSize: 12.0,
            lineWidth: 2.0
        )
    }
}
