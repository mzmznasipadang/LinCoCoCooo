//
//  AvailabilityResponse.swift
//  Coco
//
//  Created by Claude on 26/08/25.
//

import Foundation

struct AvailabilityResponse: JSONDecodable {
    let id: Int
    let packageId: Int
    let date: String
    let startTime: String
    let endTime: String
    let availableSlots: Int
    
    // Computed property for backward compatibility
    var isAvailable: Bool {
        return availableSlots > 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case packageId = "package_id"
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case availableSlots = "available_slots"
    }
    
    // Manual initializer for fallback cases
    init(id: Int, packageId: Int, date: String, startTime: String, endTime: String, availableSlots: Int) {
        self.id = id
        self.packageId = packageId
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.availableSlots = availableSlots
    }
}