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
    case tripProvider
    case itinerary
    case formInputs
    case travelerDetails
}

// MARK: - Section Model for TableView
struct BookingDetailSection {
    let type: BookingDetailSectionType
    let title: String?
    let isExpandable: Bool
    var isExpanded: Bool
    let items: [Any]
}

// MARK: - Package Info Card Model (Top section)
struct PackageInfoDisplayData {
    let imageUrl: String
    let packageName: String
    let paxRange: String
    let pricePerPax: String
    let originalPrice: String?
    let hasDiscount: Bool
    let description: String
    let duration: String
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

// MARK: - Trip Provider Model
struct TripProviderDisplayItem {
    let name: String
    let description: String
    let imageUrl: String
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
