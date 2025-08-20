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
        
        // 2. Itinerary Section (Collapsible)
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
        
        // 3. Facilities Section (Collapsible)
        let facilityItems = createFacilityItems(from: activityDetail)
        if !facilityItems.isEmpty {
            sections.append(
                BookingDetailSection(
                    type: .facilities,
                    title: "Facilities",
                    isExpandable: true,
                    isExpanded: false,
                    items: facilityItems
                )
            )
        }
        
        // 4. Terms & Conditions Section (Collapsible)
        let termsItems = createTermsItems(from: activityDetail)
        if !termsItems.isEmpty {
            sections.append(
                BookingDetailSection(
                    type: .termsAndConditions,
                    title: "Terms and Conditions",
                    isExpandable: true,
                    isExpanded: false,
                    items: termsItems
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
        
        return PackageInfoDisplayData(
            imageUrl: selectedPackage.imageUrlString, // Note: different property name
            packageName: selectedPackage.name,
            paxRange: paxRange,
            pricePerPax: "\(selectedPackage.price)/pax",
            originalPrice: nil, // Not available in current model
            hasDiscount: false
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
    
    // MARK: - Facilities Transform
    private static func createFacilityItems(from activity: ActivityDetailDataModel) -> [FacilityDisplayItem] {
        // Map from tripFacilities
        let facilities = activity.tripFacilities.content
        
        // Map facility names to icons (you might want to create a mapping dictionary)
        return facilities.map { facilityName in
            FacilityDisplayItem(
                iconName: mapFacilityToIcon(facilityName),
                name: facilityName,
                isIncluded: true, // All facilities from tripFacilities are included
                description: nil
            )
        }
    }
    
    // MARK: - Terms & Conditions Transform
    private static func createTermsItems(from activity: ActivityDetailDataModel) -> [TermsDisplayItem] {
        // The tnc field appears to be a string about cancellation
        // You might want to parse this or structure it differently
        
        var items: [TermsDisplayItem] = []
        
        // Add cancellation policy from tnc
        if !activity.tnc.isEmpty {
            items.append(
                TermsDisplayItem(
                    title: "Cancellation Policy",
                    content: activity.tnc,
                    bulletPoints: nil,
                    isImportant: true
                )
            )
        }
        
        // Add other standard terms if needed
        items.append(
            TermsDisplayItem(
                title: "Booking Requirements",
                content: "Please ensure all participants meet the requirements.",
                bulletPoints: [
                    "Valid ID required",
                    "Arrive 15 minutes before scheduled time",
                    "Follow safety instructions"
                ],
                isImportant: false
            )
        )
        
        // Add provider information as a term
        if let provider = activity.providerDetail.content as? ActivityDetailDataModel.ProviderDetail {
            items.append(
                TermsDisplayItem(
                    title: "About \(provider.name)",
                    content: provider.description,
                    bulletPoints: nil,
                    isImportant: false
                )
            )
        }
        
        return items
    }
    
    // MARK: - Helper Methods
    
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
    
    private static func mapFacilityToIcon(_ facilityName: String) -> String {
        // Create a mapping of facility names to SF Symbol icons
        let lowercased = facilityName.lowercased()
        
        // Add more mappings based on your actual facility names
        if lowercased.contains("transport") || lowercased.contains("transfer") || lowercased.contains("pickup") {
            return "bus.fill"
        } else if lowercased.contains("meal") || lowercased.contains("lunch") || lowercased.contains("breakfast") || lowercased.contains("food") {
            return "fork.knife"
        } else if lowercased.contains("guide") || lowercased.contains("instructor") {
            return "person.2.fill"
        } else if lowercased.contains("insurance") || lowercased.contains("safety") {
            return "shield.checkered"
        } else if lowercased.contains("photo") || lowercased.contains("camera") {
            return "camera.fill"
        } else if lowercased.contains("ticket") || lowercased.contains("entrance") {
            return "ticket.fill"
        } else if lowercased.contains("equipment") || lowercased.contains("gear") {
            return "backpack.fill"
        } else if lowercased.contains("water") || lowercased.contains("drink") || lowercased.contains("beverage") {
            return "drop.fill"
        } else if lowercased.contains("wifi") || lowercased.contains("internet") {
            return "wifi"
        } else if lowercased.contains("parking") {
            return "car.fill"
        } else {
            // Default icon for unknown facilities
            return "checkmark.circle.fill"
        }
    }
}
