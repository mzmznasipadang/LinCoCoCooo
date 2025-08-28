//
//  FormScheduleDataFormatter.swift
//  Coco
//
//  Created by Claude on 28/08/25.
//

import Foundation

/// Helper class for formatting data in the FormSchedule context
final class FormScheduleDataFormatter {
    
    /// Formats duration with start and end times
    /// - Parameters:
    ///   - startTime: Start time in HH:mm:ss format
    ///   - endTime: End time in HH:mm:ss format
    /// - Returns: Formatted duration string like "09:00-17:00 (8 Hours)"
    static func formatDurationWithTimes(startTime: String, endTime: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss" // API format
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm" // Display format
        
        guard let startDate = dateFormatter.date(from: startTime),
              let endDate = dateFormatter.date(from: endTime) else {
            return "\(startTime)-\(endTime)" // Fallback if parsing fails
        }
        
        let startDisplay = displayFormatter.string(from: startDate)
        let endDisplay = displayFormatter.string(from: endDate)
        
        // Calculate duration
        let duration = endDate.timeIntervalSince(startDate)
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        let durationText: String
        if minutes == 0 {
            durationText = "\(hours) Hour\(hours != 1 ? "s" : "")"
        } else if hours == 0 {
            durationText = "\(minutes) Minute\(minutes != 1 ? "s" : "")"
        } else {
            durationText = "\(hours) Hour\(hours != 1 ? "s" : "") \(minutes) Minute\(minutes != 1 ? "s" : "")"
        }
        
        return "\(startDisplay)-\(endDisplay) (\(durationText))"
    }
    
    /// Builds price details data from current state
    /// - Parameters:
    ///   - chosenDate: Selected date or nil
    ///   - participantText: Participant count as string
    ///   - selectedPackage: Selected package for pricing
    ///   - travelerName: Current traveler name
    /// - Returns: PriceDetailsData object
    static func buildPriceDetailsData(
        chosenDate: Date?,
        participantText: String,
        selectedPackage: ActivityDetailDataModel.Package?,
        travelerName: String
    ) -> PriceDetailsData {
        let selectedDate: String
        if let date = chosenDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, dd MMM yyyy"
            selectedDate = formatter.string(from: date)
        } else {
            selectedDate = "Select Date"
        }
        
        let participantCount = Int(participantText) ?? 1
        let pricePerPerson = selectedPackage?.pricePerPerson ?? 0
        let totalPrice = pricePerPerson * Double(participantCount)
        
        return PriceDetailsData(
            selectedDate: selectedDate,
            participantCount: participantCount,
            travelerName: travelerName,
            totalPrice: "Rp\(Int(totalPrice).formatted())"
        )
    }
}
