//
//  AvailabilityResponse.swift
//  Coco
//
//  Created by Claude on 26/08/25.
//

import Foundation

struct AvailabilityResponse: JSONDecodable {
    let availableSlots: Int
    let isAvailable: Bool
    
    enum CodingKeys: String, CodingKey {
        case availableSlots = "available_slots"
        case isAvailable = "is_available"
    }
}