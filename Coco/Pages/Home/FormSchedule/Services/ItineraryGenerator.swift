//
//  ItineraryGenerator.swift
//  Coco
//
//  Created by Claude on 28/08/25.
//

import Foundation

/// Service responsible for generating dynamic itineraries based on activity data
final class ItineraryGenerator {
    
    /// Generates itinerary items based on package and activity information
    /// - Parameters:
    ///   - selectedPackage: The selected package containing timing and details
    ///   - activityTitle: Title of the activity
    ///   - location: Location of the activity
    /// - Returns: Array of itinerary display items
    static func generateItineraryItems(
        selectedPackage: ActivityDetailDataModel.Package,
        activityTitle: String,
        location: String
    ) -> [ItineraryDisplayItem] {
        
        // Parse start and end times from the package
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm"
        
        guard let startDate = dateFormatter.date(from: selectedPackage.startTime),
              let endDate = dateFormatter.date(from: selectedPackage.endTime) else {
            // Fallback to basic schedule if parsing fails
            return createBasicItinerary()
        }
        
        let startTime = displayFormatter.string(from: startDate)
        let endTime = displayFormatter.string(from: endDate)
        
        // Calculate total duration in hours
        let totalDuration = endDate.timeIntervalSince(startDate)
        let totalHours = Int(totalDuration) / 3600
        
        // Generate meaningful itinerary based on activity type and duration
        let items = createDynamicItinerary(
            activityTitle: activityTitle,
            packageName: selectedPackage.name,
            startTime: startTime,
            endTime: endTime,
            durationHours: totalHours,
            location: location
        )
        
        return items
    }
    
    // MARK: - Private Helper Methods
    
    private static func createDynamicItinerary(
        activityTitle: String,
        packageName: String,
        startTime: String,
        endTime: String,
        durationHours: Int,
        location: String
    ) -> [ItineraryDisplayItem] {
        
        var items: [ItineraryDisplayItem] = []
        
        // Determine activity type from title to generate appropriate itinerary
        let activityLower = activityTitle.lowercased()
        let packageLower = packageName.lowercased()
        
        if activityLower.contains("snorkel") || packageLower.contains("snorkel") {
            items = createSnorkelingItinerary(startTime: startTime, endTime: endTime, location: location)
        } else if activityLower.contains("dive") || packageLower.contains("dive") {
            items = createDivingItinerary(startTime: startTime, endTime: endTime, location: location)
        } else if activityLower.contains("tour") || activityLower.contains("combo") {
            items = createTourItinerary(startTime: startTime, endTime: endTime, location: location, durationHours: durationHours)
        } else if activityLower.contains("hike") || activityLower.contains("trekking") {
            items = createHikingItinerary(startTime: startTime, endTime: endTime, location: location)
        } else {
            // Default generic itinerary
            items = createGenericItinerary(startTime: startTime, endTime: endTime, location: location)
        }
        
        // Mark first and last items
        for (index, _) in items.enumerated() {
            items[index] = ItineraryDisplayItem(
                time: items[index].time,
                title: items[index].title,
                description: items[index].description,
                duration: items[index].duration,
                isFirstItem: index == 0,
                isLastItem: index == items.count - 1
            )
        }
        
        return items
    }
    
    private static func createSnorkelingItinerary(startTime: String, endTime: String, location: String) -> [ItineraryDisplayItem] {
        return [
            ItineraryDisplayItem(
                time: startTime,
                title: "Meet at Harbor",
                description: "Gather at departure point and equipment briefing",
                duration: "30 min",
                isFirstItem: true,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 30),
                title: "Boat Departure",
                description: "Sail to \(location) snorkeling spots",
                duration: "45 min",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 75),
                title: "Snorkeling Session",
                description: "Explore underwater coral reefs and marine life",
                duration: "2.5 hours",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 225),
                title: "Lunch Break",
                description: "Enjoy local cuisine on the boat or island",
                duration: "1 hour",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: endTime,
                title: "Return to Harbor",
                description: "Journey back and trip conclusion",
                duration: "45 min",
                isFirstItem: false,
                isLastItem: true
            )
        ]
    }
    
    private static func createDivingItinerary(startTime: String, endTime: String, location: String) -> [ItineraryDisplayItem] {
        return [
            ItineraryDisplayItem(
                time: startTime,
                title: "Dive Center Check-in",
                description: "Equipment setup and safety briefing",
                duration: "45 min",
                isFirstItem: true,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 45),
                title: "Boat Transfer",
                description: "Travel to \(location) dive sites",
                duration: "30 min",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 75),
                title: "First Dive",
                description: "Explore underwater wrecks and coral formations",
                duration: "1 hour",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 195),
                title: "Second Dive",
                description: "Discover diverse marine ecosystems",
                duration: "1 hour",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: endTime,
                title: "Return & Debrief",
                description: "Equipment return and dive log completion",
                duration: "30 min",
                isFirstItem: false,
                isLastItem: true
            )
        ]
    }
    
    private static func createTourItinerary(startTime: String, endTime: String, location: String, durationHours: Int) -> [ItineraryDisplayItem] {
        return [
            ItineraryDisplayItem(
                time: startTime,
                title: "Tour Departure",
                description: "Meet guide and begin \(location) exploration",
                duration: "30 min",
                isFirstItem: true,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 30),
                title: "First Destination",
                description: "Visit main attractions and scenic viewpoints",
                duration: "\(max(1, durationHours/3)) hours",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 30 + (durationHours * 60 / 3)),
                title: "Cultural Experience",
                description: "Learn about local history and traditions",
                duration: "\(max(1, durationHours/3)) hours",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 30 + (durationHours * 120 / 3)),
                title: "Local Lunch",
                description: "Taste authentic regional cuisine",
                duration: "1 hour",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: endTime,
                title: "Tour Conclusion",
                description: "Return to starting point with memories",
                duration: "30 min",
                isFirstItem: false,
                isLastItem: true
            )
        ]
    }
    
    private static func createHikingItinerary(startTime: String, endTime: String, location: String) -> [ItineraryDisplayItem] {
        return [
            ItineraryDisplayItem(
                time: startTime,
                title: "Trailhead Assembly",
                description: "Meet guide and equipment check at \(location)",
                duration: "30 min",
                isFirstItem: true,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 30),
                title: "Begin Ascent",
                description: "Start hiking through scenic trails",
                duration: "2 hours",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 150),
                title: "Summit/Viewpoint",
                description: "Reach peak and enjoy panoramic views",
                duration: "1 hour",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 210),
                title: "Rest & Refreshment",
                description: "Break for snacks and photos",
                duration: "30 min",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: endTime,
                title: "Descent & Return",
                description: "Safe return journey to starting point",
                duration: "1.5 hours",
                isFirstItem: false,
                isLastItem: true
            )
        ]
    }
    
    private static func createGenericItinerary(startTime: String, endTime: String, location: String) -> [ItineraryDisplayItem] {
        return [
            ItineraryDisplayItem(
                time: startTime,
                title: "Activity Begins",
                description: "Meet your guide and start the \(location) experience",
                duration: "30 min",
                isFirstItem: true,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 30),
                title: "Main Activity",
                description: "Enjoy the highlights of this unique experience",
                duration: "3 hours",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: addMinutesToTime(startTime, 240),
                title: "Break Time",
                description: "Rest and refreshments",
                duration: "30 min",
                isFirstItem: false,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: endTime,
                title: "Activity Ends",
                description: "Conclusion of your \(location) adventure",
                duration: "30 min",
                isFirstItem: false,
                isLastItem: true
            )
        ]
    }
    
    private static func createBasicItinerary() -> [ItineraryDisplayItem] {
        return [
            ItineraryDisplayItem(
                time: "09:00",
                title: "Activity Starts",
                description: "Begin your adventure",
                duration: "30 min",
                isFirstItem: true,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: "17:00",
                title: "Activity Ends",
                description: "Conclude your experience",
                duration: "30 min",
                isFirstItem: false,
                isLastItem: true
            )
        ]
    }
    
    private static func addMinutesToTime(_ timeString: String, _ minutes: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let time = formatter.date(from: timeString),
              let newTime = Calendar.current.date(byAdding: .minute, value: minutes, to: time) else {
            return timeString
        }
        
        return formatter.string(from: newTime)
    }
}