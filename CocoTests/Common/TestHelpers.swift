//
//  TestHelpers.swift
//  CocoTests
//
//  Created by Claude on 27/08/25.
//

import Foundation
import Testing
@testable import Coco

// MARK: - Test Utilities

/// Helper class for creating mock data and common test utilities
class TestHelpers {
    
    // MARK: - Mock Activity Data
    
    static func createMockActivityDetailDataModel(
        id: Int = 1,
        title: String = "Test Activity",
        location: String = "Test Location"
    ) throws -> ActivityDetailDataModel {
        // Use the existing JSON data approach like other tests
        let list: ActivityModelArray = try JSONReader.getObjectFromJSON(with: "activities")
        guard !list.values.isEmpty else {
            throw TestError.invalidMockData("No activities found in test JSON")
        }
        return ActivityDetailDataModel(list.values[0])
    }
    
    static func createMockActivityDetailDataModelFromJSON() throws -> ActivityDetailDataModel {
        // Helper method to create ActivityDetailDataModel from existing JSON test data
        let list: ActivityModelArray = try JSONReader.getObjectFromJSON(with: "activities")
        guard !list.values.isEmpty else {
            throw TestError.invalidMockData("No activities found in test JSON")
        }
        return ActivityDetailDataModel(list.values[0])
    }
    
    static func createMockPackage(
        id: Int = 1,
        name: String = "Test Package",
        hostName: String = "Test Host",
        pricePerPerson: Double = 500000,
        startTime: String = "09:00",
        endTime: String = "17:00"
    ) -> ActivityDetailDataModel.Package {
        return ActivityDetailDataModel.Package(
            imageUrlString: "https://example.com/package.jpg",
            name: name,
            description: "2 - 4 person",
            price: "Rp \(Int(pricePerPerson).formatted())",
            pricePerPerson: pricePerPerson,
            minParticipants: 2,
            maxParticipants: 4,
            id: id,
            hostName: hostName,
            hostBio: "Professional \(hostName) guide",
            hostProfileImageUrl: "https://example.com/host\(id).jpg",
            startTime: startTime,
            endTime: endTime
        )
    }
    
    // MARK: - Mock Network Responses
    
    static func createMockCreateBookingResponse(
        message: String = "Booking created successfully",
        success: Bool = true,
        bookingId: Int = 12345,
        status: String = "confirmed"
    ) -> CreateBookingResponse {
        let destination = BookingDestination(
            id: 1,
            name: "Test Destination",
            imageUrl: "https://example.com/destination.jpg",
            description: "Beautiful test destination"
        )
        
        let bookingDetails = BookingDetails(
            status: status,
            bookingId: bookingId,
            startTime: "09:00",
            destination: destination,
            totalPrice: 1000000.0,
            packageName: "Test Package",
            participants: 2,
            activityDate: "2025-08-28",
            activityTitle: "Test Activity",
            bookingCreatedAt: "2025-08-27T10:00:00Z",
            address: "Test Address"
        )
        
        return CreateBookingResponse(
            message: message,
            success: success,
            bookingDetails: bookingDetails
        )
    }
    
    static func createMockAvailabilityResponse(
        id: Int = 1,
        packageId: Int = 46,
        date: String = "2025-08-31",
        startTime: String = "09:00",
        endTime: String = "17:00",
        availableSlots: Int = 10
    ) -> AvailabilityResponse {
        return AvailabilityResponse(
            id: id,
            packageId: packageId,
            date: date,
            startTime: startTime,
            endTime: endTime,
            availableSlots: availableSlots
        )
    }
    
    // MARK: - Date Helpers
    
    static func createDate(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: dateComponents) ?? Date()
    }
    
    static func createDateString(year: Int, month: Int, day: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: createDate(year: year, month: month, day: day))
    }
    
    // MARK: - Validation Helpers
    
    static func validateItineraryStructure(_ itinerary: [ItineraryDisplayItem]) -> Bool {
        guard !itinerary.isEmpty else { return false }
        
        // Check first item
        guard itinerary.first?.isFirstItem == true else { return false }
        
        // Check last item
        guard itinerary.last?.isLastItem == true else { return false }
        
        // Check middle items
        for (index, item) in itinerary.enumerated() {
            if index == 0 {
                guard item.isFirstItem && !item.isLastItem else { return false }
            } else if index == itinerary.count - 1 {
                guard !item.isFirstItem && item.isLastItem else { return false }
            } else {
                guard !item.isFirstItem && !item.isLastItem else { return false }
            }
        }
        
        return true
    }
    
    static func validateTimeProgression(_ itinerary: [ItineraryDisplayItem]) -> Bool {
        guard itinerary.count > 1 else { return true }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        for i in 0..<(itinerary.count - 1) {
            guard let currentTime = timeFormatter.date(from: itinerary[i].time ?? ""),
                  let nextTime = timeFormatter.date(from: itinerary[i + 1].time ?? "") else {
                return false
            }
            
            // Times should progress forward (or at least not go backward)
            if nextTime < currentTime {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Mock Expectation Helper
    
    /// Simple async expectation helper for testing async operations
    class AsyncExpectation {
        private var isFulfilled = false
        private let timeout: TimeInterval
        
        init(timeout: TimeInterval = 2.0) {
            self.timeout = timeout
        }
        
        func fulfill() {
            isFulfilled = true
        }
        
        func wait() async throws {
            let startTime = Date()
            
            while !isFulfilled {
                if Date().timeIntervalSince(startTime) > timeout {
                    throw TestError.timeout
                }
                try await Task.sleep(nanoseconds: 10_000_000) // 10ms
            }
        }
    }
}

// MARK: - Test Errors

enum TestError: Error, CustomStringConvertible {
    case timeout
    case unexpectedResult(String)
    case invalidMockData(String)
    
    var description: String {
        switch self {
        case .timeout:
            return "Test operation timed out"
        case .unexpectedResult(let message):
            return "Unexpected test result: \(message)"
        case .invalidMockData(let message):
            return "Invalid mock data: \(message)"
        }
    }
}

// MARK: - Assert Helpers

/// Additional assertion helpers for common test scenarios
struct TestAssertions {
    
    /// Asserts that a booking detail section contains expected items
    static func assertBookingSection(
        _ section: BookingDetailSection,
        type: BookingDetailSectionType,
        hasItems: Bool = true,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        #expect(section.type == type, "Section type should be \(type)")
        
        if hasItems {
            #expect(!section.items.isEmpty, "Section should have items")
        }
    }
    
    /// Asserts that a trip provider item has expected properties
    static func assertTripProvider(
        _ item: TripProviderDisplayItem,
        name: String,
        hasDescription: Bool = true,
        hasImageUrl: Bool = true,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        #expect(item.name == name, "Provider name should match")
        
        if hasDescription {
            #expect(!item.description.isEmpty, "Provider should have description")
        }
        
        if hasImageUrl {
            #expect(!item.imageUrl.isEmpty, "Provider should have image URL")
        }
    }
    
    /// Asserts that an itinerary has the expected structure and content
    static func assertItinerary(
        _ items: [ItineraryDisplayItem],
        expectedCount: Int,
        hasValidStructure: Bool = true,
        hasProgressingTime: Bool = true,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        #expect(items.count == expectedCount, "Itinerary should have \(expectedCount) items")
        
        if hasValidStructure {
            #expect(TestHelpers.validateItineraryStructure(items), "Itinerary should have valid structure")
        }
        
        if hasProgressingTime {
            #expect(TestHelpers.validateTimeProgression(items), "Itinerary times should progress forward")
        }
    }
}
