//
//  ItineraryGeneratorTests.swift
//  CocoTests
//
//  Created by Claude on 27/08/25.
//

import Foundation
import Testing
@testable import Coco

struct ItineraryGeneratorTests {
    
    // MARK: - Test Data Setup
    
    private struct TestPackage {
        static let divingPackage = ActivityDetailDataModel.Package(
            imageUrlString: "https://example.com/diving.jpg",
            name: "Professional Diving Experience",
            description: "2 - 4 person",
            price: "Rp 500,000",
            pricePerPerson: 500000,
            minParticipants: 2,
            maxParticipants: 4,
            id: 1,
            hostName: "Ocean Adventures",
            startTime: "08:00",
            endTime: "16:00",
            hostBio: "Professional diving instructor",
            hostProfileImageUrl: "https://example.com/host.jpg"
        )
        
        static let hikingPackage = ActivityDetailDataModel.Package(
            imageUrlString: "https://example.com/hiking.jpg",
            name: "Mountain Trekking Adventure",
            description: "1 - 6 person",
            price: "Rp 300,000",
            pricePerPerson: 300000,
            minParticipants: 1,
            maxParticipants: 6,
            id: 2,
            hostName: "Mountain Guides",
            startTime: "06:00",
            endTime: "14:00",
            hostBio: "Experienced mountain guide",
            hostProfileImageUrl: "https://example.com/guide.jpg"
        )
        
        static let cityTourPackage = ActivityDetailDataModel.Package(
            imageUrlString: "https://example.com/city.jpg",
            name: "Historical City Walking Tour",
            description: "1 - 10 person",
            price: "Rp 150,000",
            pricePerPerson: 150000,
            minParticipants: 1,
            maxParticipants: 10,
            id: 3,
            hostName: "City Explorers",
            startTime: "09:00",
            endTime: "17:00",
            hostBio: "Local history expert",
            hostProfileImageUrl: "https://example.com/local-guide.jpg"
        )
        
        static let culinaryPackage = ActivityDetailDataModel.Package(
            imageUrlString: "https://example.com/cooking.jpg",
            name: "Traditional Cooking Class",
            description: "2 - 8 person",
            price: "Rp 400,000",
            pricePerPerson: 400000,
            minParticipants: 2,
            maxParticipants: 8,
            id: 4,
            hostName: "Chef Santika",
            startTime: "10:00",
            endTime: "15:00",
            hostBio: "Traditional cuisine chef",
            hostProfileImageUrl: "https://example.com/chef.jpg"
        )
        
        static let genericPackage = ActivityDetailDataModel.Package(
            imageUrlString: "https://example.com/generic.jpg",
            name: "Adventure Experience",
            description: "1 - 5 person",
            price: "Rp 250,000",
            pricePerPerson: 250000,
            minParticipants: 1,
            maxParticipants: 5,
            id: 5,
            hostName: "Adventure Co",
            startTime: "11:00",
            endTime: "15:00",
            hostBio: "Adventure specialists",
            hostProfileImageUrl: "https://example.com/adventure.jpg"
        )
    }
    
    // MARK: - Diving Itinerary Tests
    
    @Test("diving itinerary - should generate 6 segments with correct activities")
    func divingItinerary_whenDivingActivity_shouldGenerate6Segments() throws {
        // --- GIVEN ---
        let package = TestPackage.divingPackage
        let activityTitle = "Snorkeling Adventure in Crystal Waters"
        let location = "Nusa Penida"
        let durationMinutes = 480 // 8 hours
        let facilities = ["Snorkeling Equipment", "Life Jacket"]
        
        // --- WHEN ---
        let itinerary = ItineraryGenerator.generateDetailedItinerary(
            for: package,
            activityTitle: activityTitle,
            location: location,
            durationMinutes: durationMinutes,
            facilities: facilities
        )
        
        // --- THEN ---
        #expect(itinerary.count == 6)
        
        // Verify first item
        #expect(itinerary[0].time == "08:00")
        #expect(itinerary[0].title == "Meet & Greet")
        #expect(itinerary[0].description.contains("Meet your instructor at Nusa Penida"))
        #expect(itinerary[0].duration == "30 min")
        #expect(itinerary[0].isFirstItem == true)
        #expect(itinerary[0].isLastItem == false)
        
        // Verify middle items have proper structure
        #expect(itinerary[1].title == "Equipment Setup")
        #expect(itinerary[2].title == "Boat Departure")
        #expect(itinerary[3].title == "First Dive/Snorkel")
        #expect(itinerary[4].title == "Rest & Lunch")
        
        // Verify last item
        #expect(itinerary[5].title == "Return Journey")
        #expect(itinerary[5].isFirstItem == false)
        #expect(itinerary[5].isLastItem == true)
    }
    
    // MARK: - Hiking Itinerary Tests
    
    @Test("hiking itinerary - should generate 5 segments with trekking activities")
    func hikingItinerary_whenHikingActivity_shouldGenerate5Segments() throws {
        // --- GIVEN ---
        let package = TestPackage.hikingPackage
        let activityTitle = "Mount Batur Sunrise Trekking"
        let location = "Mount Batur"
        let durationMinutes = 480
        let facilities = ["Hiking Gear", "Flashlight"]
        
        // --- WHEN ---
        let itinerary = ItineraryGenerator.generateDetailedItinerary(
            for: package,
            activityTitle: activityTitle,
            location: location,
            durationMinutes: durationMinutes,
            facilities: facilities
        )
        
        // --- THEN ---
        #expect(itinerary.count == 5)
        #expect(itinerary[0].title == "Trail Preparation")
        #expect(itinerary[0].description.contains("Mount Batur"))
        #expect(itinerary[1].title == "Trail Ascent")
        #expect(itinerary[2].title == "Summit/Viewpoint")
        #expect(itinerary[3].title == "Nature Exploration")
        #expect(itinerary[4].title == "Descent & Return")
        
        // Verify time progression
        #expect(itinerary[0].time == "06:00")
        #expect(itinerary[4].time != "06:00") // Should have progressed
    }
    
    // MARK: - City Tour Itinerary Tests
    
    @Test("city tour itinerary - should generate 6 segments with cultural activities")
    func cityTourItinerary_whenCityTourActivity_shouldGenerate6Segments() throws {
        // --- GIVEN ---
        let package = TestPackage.cityTourPackage
        let activityTitle = "Historic Ubud City Tour"
        let location = "Ubud"
        let durationMinutes = 480
        let facilities = ["Transportation", "Guide"]
        
        // --- WHEN ---
        let itinerary = ItineraryGenerator.generateDetailedItinerary(
            for: package,
            activityTitle: activityTitle,
            location: location,
            durationMinutes: durationMinutes,
            facilities: facilities
        )
        
        // --- THEN ---
        #expect(itinerary.count == 6)
        #expect(itinerary[0].title == "Tour Begins")
        #expect(itinerary[0].description.contains("Ubud"))
        #expect(itinerary[1].title == "Historical District")
        #expect(itinerary[2].title == "Local Market")
        #expect(itinerary[3].title == "Cultural Sites")
        #expect(itinerary[4].title == "Local Cuisine")
        #expect(itinerary[5].title == "Tour Conclusion")
    }
    
    // MARK: - Culinary Itinerary Tests
    
    @Test("culinary itinerary - should generate 5 segments with cooking activities")
    func culinaryItinerary_whenCookingActivity_shouldGenerate5Segments() throws {
        // --- GIVEN ---
        let package = TestPackage.culinaryPackage
        let activityTitle = "Balinese Cooking Class Experience"
        let location = "Traditional Kitchen, Sanur"
        let durationMinutes = 300 // 5 hours
        let facilities = ["Cooking Equipment", "Ingredients"]
        
        // --- WHEN ---
        let itinerary = ItineraryGenerator.generateDetailedItinerary(
            for: package,
            activityTitle: activityTitle,
            location: location,
            durationMinutes: durationMinutes,
            facilities: facilities
        )
        
        // --- THEN ---
        #expect(itinerary.count == 5)
        #expect(itinerary[0].title == "Welcome & Introduction")
        #expect(itinerary[0].description.contains("Traditional Kitchen, Sanur"))
        #expect(itinerary[1].title == "Market Visit")
        #expect(itinerary[2].title == "Cooking Session")
        #expect(itinerary[3].title == "Feast & Stories")
        #expect(itinerary[4].title == "Recipe Sharing")
    }
    
    // MARK: - Generic Itinerary Tests
    
    @Test("generic itinerary - should generate 4 segments for unknown activity types")
    func genericItinerary_whenUnknownActivity_shouldGenerate4Segments() throws {
        // --- GIVEN ---
        let package = TestPackage.genericPackage
        let activityTitle = "Amazing Adventure Experience"
        let location = "Secret Location"
        let durationMinutes = 240 // 4 hours
        let facilities = ["Equipment", "Guide"]
        
        // --- WHEN ---
        let itinerary = ItineraryGenerator.generateDetailedItinerary(
            for: package,
            activityTitle: activityTitle,
            location: location,
            durationMinutes: durationMinutes,
            facilities: facilities
        )
        
        // --- THEN ---
        #expect(itinerary.count == 4)
        #expect(itinerary[0].title == "Activity Begins")
        #expect(itinerary[0].description.contains("Amazing Adventure Experience"))
        #expect(itinerary[1].title == "Main Activity")
        #expect(itinerary[1].description.contains("Secret Location"))
        #expect(itinerary[2].title == "Break & Exploration")
        #expect(itinerary[3].title == "Activity Conclusion")
    }
    
    // MARK: - Time Parsing Tests
    
    @Test("time parsing - should handle invalid time formats gracefully")
    func timeParsing_whenInvalidFormat_shouldUseFallback() throws {
        // --- GIVEN ---
        let packageWithInvalidTime = ActivityDetailDataModel.Package(
            imageUrlString: "https://example.com/test.jpg",
            name: "Test Activity",
            description: "1 - 2 person",
            price: "Rp 100,000",
            pricePerPerson: 100000,
            minParticipants: 1,
            maxParticipants: 2,
            id: 99,
            hostName: "Test Host",
            startTime: "invalid-time",
            endTime: "also-invalid",
            hostBio: "Test bio",
            hostProfileImageUrl: "https://example.com/test-host.jpg"
        )
        
        // --- WHEN ---
        let itinerary = ItineraryGenerator.generateDetailedItinerary(
            for: packageWithInvalidTime,
            activityTitle: "Test Activity",
            location: "Test Location",
            durationMinutes: 120,
            facilities: []
        )
        
        // --- THEN ---
        #expect(itinerary.count == 2) // Should fallback to simple start/end
        #expect(itinerary[0].time == "invalid-time")
        #expect(itinerary[1].time == "also-invalid")
        #expect(itinerary[0].title == "Activity Start")
        #expect(itinerary[1].title == "Activity End")
    }
    
    // MARK: - Activity Type Detection Tests
    
    @Test("activity type detection - should detect diving keywords")
    func activityTypeDetection_whenDivingKeywords_shouldCreateDivingItinerary() throws {
        // --- GIVEN ---
        let testCases = [
            "Amazing Diving Experience",
            "Snorkeling Adventure",
            "Scuba Diving Tour",
            "SNORKELING with Turtles"
        ]
        
        for activityTitle in testCases {
            // --- WHEN ---
            let itinerary = ItineraryGenerator.generateDetailedItinerary(
                for: TestPackage.divingPackage,
                activityTitle: activityTitle,
                location: "Test Location",
                durationMinutes: 480,
                facilities: []
            )
            
            // --- THEN ---
            #expect(itinerary.count == 6) // Diving itinerary has 6 segments
            #expect(itinerary[0].title == "Meet & Greet")
        }
    }
    
    @Test("activity type detection - should detect hiking keywords")
    func activityTypeDetection_whenHikingKeywords_shouldCreateHikingItinerary() throws {
        // --- GIVEN ---
        let testCases = [
            "Mountain Hiking Adventure",
            "Volcano Trekking Experience",
            "Forest Hiking Trail",
            "TREKKING to Summit"
        ]
        
        for activityTitle in testCases {
            // --- WHEN ---
            let itinerary = ItineraryGenerator.generateDetailedItinerary(
                for: TestPackage.hikingPackage,
                activityTitle: activityTitle,
                location: "Test Location",
                durationMinutes: 480,
                facilities: []
            )
            
            // --- THEN ---
            #expect(itinerary.count == 5) // Hiking itinerary has 5 segments
            #expect(itinerary[0].title == "Trail Preparation")
        }
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("edge cases - should handle very short time duration")
    func edgeCases_whenShortDuration_shouldStillGenerateSegments() throws {
        // --- GIVEN ---
        let shortPackage = ActivityDetailDataModel.Package(
            imageUrlString: "https://example.com/short.jpg",
            name: "Quick Experience",
            description: "1 - 2 person",
            price: "Rp 50,000",
            pricePerPerson: 50000,
            minParticipants: 1,
            maxParticipants: 2,
            id: 98,
            hostName: "Quick Host",
            startTime: "14:00",
            endTime: "14:30", // Only 30 minutes
            hostBio: "Quick experiences",
            hostProfileImageUrl: "https://example.com/quick-host.jpg"
        )
        
        // --- WHEN ---
        let itinerary = ItineraryGenerator.generateDetailedItinerary(
            for: shortPackage,
            activityTitle: "Quick City Tour",
            location: "Downtown",
            durationMinutes: 30,
            facilities: []
        )
        
        // --- THEN ---
        #expect(itinerary.count == 6) // Should still generate city tour segments
        #expect(itinerary[0].time == "14:00")
        #expect(itinerary.last?.time != "14:00") // Should progress in time
    }
    
    @Test("edge cases - should handle empty location and facilities")
    func edgeCases_whenEmptyInputs_shouldStillWork() throws {
        // --- GIVEN ---
        let package = TestPackage.genericPackage
        
        // --- WHEN ---
        let itinerary = ItineraryGenerator.generateDetailedItinerary(
            for: package,
            activityTitle: "",
            location: "",
            durationMinutes: 0,
            facilities: []
        )
        
        // --- THEN ---
        #expect(itinerary.count == 4) // Generic itinerary
        #expect(itinerary[0].isFirstItem == true)
        #expect(itinerary.last?.isLastItem == true)
    }
}