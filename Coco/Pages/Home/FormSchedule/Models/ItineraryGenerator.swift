//
//  ItineraryGenerator.swift
//  Coco
//
//  Created by Claude on 27/08/25.
//

import Foundation

/// Helper struct for creating itinerary segments
struct ItinerarySegment {
    let time: Date
    let title: String
    let description: String
    let duration: String
}

/// Generator for creating detailed itineraries based on activity types
class ItineraryGenerator {
    
    /// Generates a detailed itinerary based on package information and activity details
    static func generateDetailedItinerary(
        for package: ActivityDetailDataModel.Package,
        activityTitle: String,
        location: String,
        durationMinutes: Int,
        facilities: [String],
        startTime: String,
        endTime: String
    ) -> [ItineraryDisplayItem] {
        
        // Parse start time to calculate intermediate times
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        guard let startDate = timeFormatter.date(from: startTime),
              let endDate = timeFormatter.date(from: endTime) else {
            // Fallback if time parsing fails
            return createFallbackItinerary(startTime: startTime, endTime: endTime, activityTitle: activityTitle)
        }
        
        let totalDuration = endDate.timeIntervalSince(startDate)
        let segments = createTimeSegments(
            startDate: startDate,
            totalDuration: totalDuration,
            activityTitle: activityTitle,
            location: location
        )
        
        var items: [ItineraryDisplayItem] = []
        
        for (index, segment) in segments.enumerated() {
            let isFirst = index == 0
            let isLast = index == segments.count - 1
            
            let item = ItineraryDisplayItem(
                time: timeFormatter.string(from: segment.time),
                title: segment.title,
                description: segment.description,
                duration: segment.duration,
                isFirstItem: isFirst,
                isLastItem: isLast
            )
            items.append(item)
        }
        
        return items
    }
    
    /// Creates time segments for the itinerary
    private static func createTimeSegments(
        startDate: Date,
        totalDuration: TimeInterval,
        activityTitle: String,
        location: String
    ) -> [ItinerarySegment] {
        // Determine activity type based on title and create appropriate segments
        if activityTitle.lowercased().contains("diving") ||
           activityTitle.lowercased().contains("snorkeling") {
            return createDivingItinerary(startDate: startDate, totalDuration: totalDuration, location: location)
        } else if activityTitle.lowercased().contains("hiking") ||
                  activityTitle.lowercased().contains("trekking") {
            return createHikingItinerary(startDate: startDate, totalDuration: totalDuration, location: location)
        } else if activityTitle.lowercased().contains("city") ||
                  activityTitle.lowercased().contains("tour") {
            return createCityTourItinerary(startDate: startDate, totalDuration: totalDuration, location: location)
        } else if activityTitle.lowercased().contains("cooking") ||
                  activityTitle.lowercased().contains("culinary") {
            return createCulinaryItinerary(startDate: startDate, totalDuration: totalDuration, location: location)
        } else {
            return createGenericItinerary(
                startDate: startDate,
                totalDuration: totalDuration,
                activityTitle: activityTitle,
                location: location
            )
        }
    }
    
    /// Creates diving/snorkeling specific itinerary
    private static func createDivingItinerary(
        startDate: Date,
        totalDuration: TimeInterval,
        location: String
    ) -> [ItinerarySegment] {
        let segmentDuration = totalDuration / 6 // Divide into 6 segments
        
        return [
            ItinerarySegment(
                time: startDate,
                title: "Meet & Greet",
                description: "Meet your instructor at \(location) and receive safety briefing",
                duration: "30 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration),
                title: "Equipment Setup",
                description: "Get fitted with diving/snorkeling gear and practice safety procedures",
                duration: "45 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 2),
                title: "Boat Departure",
                description: "Board the boat and head to the dive site with scenic ocean views",
                duration: "30 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 3),
                title: "First Dive/Snorkel",
                description: "Explore underwater marine life and coral reefs",
                duration: "60 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 4),
                title: "Rest & Lunch",
                description: "Relax on boat with refreshments and share diving experiences",
                duration: "45 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 5),
                title: "Return Journey",
                description: "Head back to shore with memorable underwater photos and videos",
                duration: "30 min"
            )
        ]
    }
    
    /// Creates hiking/trekking specific itinerary
    private static func createHikingItinerary(
        startDate: Date,
        totalDuration: TimeInterval,
        location: String
    ) -> [ItinerarySegment] {
        let segmentDuration = totalDuration / 5
        
        return [
            ItinerarySegment(
                time: startDate,
                title: "Trail Preparation",
                description: "Meet guide, check equipment, and warm-up exercises at \(location)",
                duration: "20 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration),
                title: "Trail Ascent",
                description: "Begin hiking journey with scenic viewpoints and photo opportunities",
                duration: "90 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 2),
                title: "Summit/Viewpoint",
                description: "Reach the peak and enjoy panoramic views with snack break",
                duration: "45 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 3),
                title: "Nature Exploration",
                description: "Discover local flora and fauna with expert guide commentary",
                duration: "60 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 4),
                title: "Descent & Return",
                description: "Safe descent with group reflection and return to starting point",
                duration: "45 min"
            )
        ]
    }
    
    /// Creates city tour specific itinerary
    private static func createCityTourItinerary(
        startDate: Date,
        totalDuration: TimeInterval,
        location: String
    ) -> [ItinerarySegment] {
        let segmentDuration = totalDuration / 6
        
        return [
            ItinerarySegment(
                time: startDate,
                title: "Tour Begins",
                description: "Meet your local guide and receive orientation about \(location)",
                duration: "15 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration),
                title: "Historical District",
                description: "Explore ancient architecture and learn about local heritage",
                duration: "60 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 2),
                title: "Local Market",
                description: "Experience vibrant local market with authentic crafts and souvenirs",
                duration: "45 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 3),
                title: "Cultural Sites",
                description: "Visit temples, museums, or cultural landmarks with guided commentary",
                duration: "75 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 4),
                title: "Local Cuisine",
                description: "Taste authentic local dishes at recommended restaurants",
                duration: "60 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 5),
                title: "Tour Conclusion",
                description: "Final Q&A, recommendations, and farewell at central location",
                duration: "15 min"
            )
        ]
    }
    
    /// Creates culinary experience specific itinerary
    private static func createCulinaryItinerary(
        startDate: Date,
        totalDuration: TimeInterval,
        location: String
    ) -> [ItinerarySegment] {
        let segmentDuration = totalDuration / 5
        
        return [
            ItinerarySegment(
                time: startDate,
                title: "Welcome & Introduction",
                description: "Meet chef and learn about local culinary traditions at \(location)",
                duration: "20 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration),
                title: "Market Visit",
                description: "Select fresh ingredients from local market with chef's guidance",
                duration: "45 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 2),
                title: "Cooking Session",
                description: "Hands-on cooking experience learning traditional recipes and techniques",
                duration: "90 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 3),
                title: "Feast & Stories",
                description: "Enjoy your prepared meal while learning about food culture and history",
                duration: "60 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 4),
                title: "Recipe Sharing",
                description: "Receive recipe cards and tips for recreating dishes at home",
                duration: "15 min"
            )
        ]
    }
    
    /// Creates generic activity itinerary
    private static func createGenericItinerary(
        startDate: Date,
        totalDuration: TimeInterval,
        activityTitle: String,
        location: String
    ) -> [ItinerarySegment] {
        let segmentDuration = totalDuration / 4
        
        return [
            ItinerarySegment(
                time: startDate,
                title: "Activity Begins",
                description: "Welcome and orientation for your \(activityTitle) experience",
                duration: "15 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration),
                title: "Main Activity",
                description: "Enjoy the primary experience at \(location)",
                duration: "120 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 2),
                title: "Break & Exploration",
                description: "Refreshment break and additional exploration opportunities",
                duration: "45 min"
            ),
            ItinerarySegment(
                time: startDate.addingTimeInterval(segmentDuration * 3),
                title: "Activity Conclusion",
                description: "Wrap-up, photos, and farewell for your memorable experience",
                duration: "30 min"
            )
        ]
    }
    
    /// Fallback itinerary when time parsing fails
    private static func createFallbackItinerary(
        startTime: String,
        endTime: String,
        activityTitle: String
    ) -> [ItineraryDisplayItem] {
        return [
            ItineraryDisplayItem(
                time: startTime,
                title: "Activity Start",
                description: "Begin your \(activityTitle) experience",
                duration: nil,
                isFirstItem: true,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: endTime,
                title: "Activity End",
                description: "Conclusion of your \(activityTitle) experience",
                duration: nil,
                isFirstItem: false,
                isLastItem: true
            )
        ]
    }
}