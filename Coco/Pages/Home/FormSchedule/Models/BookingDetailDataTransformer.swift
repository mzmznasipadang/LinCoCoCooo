//
//  BookingDetailDataTransformer.swift
//  Coco
//
//  Created by Victor Chandra on 20/08/25.
//

import Foundation
import UIKit

final class BookingDetailDataTransformer {
    
    // MARK: - Main Transform Method
    static func transform(
        activityDetail: ActivityDetailDataModel,
        selectedPackageId: Int
    ) -> [BookingDetailSection] {
        
        var sections: [BookingDetailSection] = []
        
        // 1. Package Info Section (Always visible, not collapsible)
        if let packageInfo = createPackageInfo(from: activityDetail, packageId: selectedPackageId) {
            sections.append(
                BookingDetailSection(
                    type: .packageInfo,
                    title: nil,
                    isExpandable: false,
                    isExpanded: true,
                    items: [packageInfo]
                )
            )
        }
        
        // 2. Trip Provider Section (Collapsible)
        if let tripProvider = createTripProvider(from: activityDetail) {
            sections.append(
                BookingDetailSection(
                    type: .tripProvider,
                    title: "Trip Provider",
                    isExpandable: true,
                    isExpanded: false,
                    items: [tripProvider]
                )
            )
        }
        
        // 3. Itinerary Section (Collapsible)
        let itineraryItems = createItineraryItems(from: activityDetail)
        if !itineraryItems.isEmpty {
            sections.append(
                BookingDetailSection(
                    type: .itinerary,
                    title: "Itinerary",
                    isExpandable: true,
                    isExpanded: false,
                    items: itineraryItems
                )
            )
        }
        
        return sections
    }
    
    // MARK: - Package Info Transform
    private static func createPackageInfo(
        from activity: ActivityDetailDataModel,
        packageId: Int
    ) -> PackageInfoDisplayData? {
        
        // Find selected package
        guard let selectedPackage = activity.availablePackages.content.first(where: { $0.id == packageId }) else {
            return nil
        }
        
        // Extract min/max participants from description
        // Description format: "Min.X - Max.Y"
        let paxRange = extractPaxRange(from: selectedPackage.description)
        
        // Format duration from activity detail
        let durationText = formatDuration(from: activity)
        
        return PackageInfoDisplayData(
            imageUrl: selectedPackage.imageUrlString,
            packageName: selectedPackage.name,
            paxRange: paxRange,
            pricePerPax: "\(selectedPackage.price)/pax",
            originalPrice: nil,
            hasDiscount: false,
            description: activity.detailInfomation.content,
            duration: durationText
        )
    }
    
    // MARK: - Trip Provider Transform
    private static func createTripProvider(from activity: ActivityDetailDataModel) -> TripProviderDisplayItem? {
        let provider = activity.providerDetail.content
        
        return TripProviderDisplayItem(
            name: provider.name,
            description: provider.description,
            imageUrl: provider.imageUrlString
        )
    }
    
    // MARK: - Itinerary Transform
    private static func createItineraryItems(from activity: ActivityDetailDataModel) -> [ItineraryDisplayItem] {
        // Your model doesn't have itinerary data, so keeping mock data
        // You can return empty array if you don't want to show this section
        
        // return [] // Option 1: Don't show itinerary section
        
        // Option 2: Show mock data for now
        return [
            ItineraryDisplayItem(
                time: "08:00",
                title: "Hotel Pickup",
                description: "Driver will pick you up from your hotel lobby",
                duration: "30 mins",
                isFirstItem: true,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: "09:00",
                title: "Arrive at \(activity.location)",
                description: "Registration and safety briefing",
                duration: "30 mins",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: "09:30",
                title: activity.title,
                description: "Begin your adventure experience",
                duration: "3 hours",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: "12:30",
                title: "Lunch Break",
                description: "Enjoy local cuisine",
                duration: "1 hour",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: "14:00",
                title: "Return to Hotel",
                description: "Drop off at your hotel",
                duration: "30 mins",
                isFirstItem: false,
                isLastItem: true
            )
        ]
    }
    
    
    // MARK: - Helper Methods
    
    private static func formatDuration(from activity: ActivityDetailDataModel) -> String {
        let totalMinutes = activity.durationMinutes
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        // Create a start time (default 09:00 for now, could be made dynamic)
        let startHour = 9
        let startMinute = 0
        
        // Calculate end time
        let endHour = startHour + hours + (startMinute + minutes) / 60
        let endMinute = (startMinute + minutes) % 60
        
        // Format start and end times
        let startTime = String(format: "%02d:%02d", startHour, startMinute)
        let endTime = String(format: "%02d:%02d", endHour, endMinute)
        
        // Format duration text
        let durationText: String
        if hours == 0 {
            durationText = "\(minutes) Minutes"
        } else if minutes == 0 {
            durationText = "\(hours) Hour\(hours > 1 ? "s" : "")"
        } else {
            durationText = "\(hours) Hour\(hours > 1 ? "s" : "") \(minutes) Minutes"
        }
        
        return "\(startTime)-\(endTime) (\(durationText))"
    }
    
    private static func extractPaxRange(from description: String) -> String {
        // Parse "Min.X - Max.Y" format
        // Example: "Min.1 - Max.10" -> "1-10 pax"
        
        let components = description.components(separatedBy: " - ")
        
        if components.count == 2 {
            let minPart = components[0].replacingOccurrences(of: "Min.", with: "").trimmingCharacters(in: .whitespaces)
            let maxPart = components[1].replacingOccurrences(of: "Max.", with: "").trimmingCharacters(in: .whitespaces)
            return "\(minPart)-\(maxPart) pax"
        }
        
        // Fallback to original description if parsing fails
        return description
    }
}
