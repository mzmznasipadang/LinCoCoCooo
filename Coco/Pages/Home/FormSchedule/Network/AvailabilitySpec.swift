//
//  AvailabilitySpec.swift
//  Coco
//
//  Created by Claude on 26/08/25.
//

import Foundation

struct AvailabilitySpec: JSONEncodable {
    let packageId: Int
    let date: String
    
    private enum CodingKeys: String, CodingKey {
        case packageId = "p_package_id"
        case date = "p_date"
    }
    
    init(packageId: Int, date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        self.packageId = packageId
        self.date = formatter.string(from: date)
    }
}