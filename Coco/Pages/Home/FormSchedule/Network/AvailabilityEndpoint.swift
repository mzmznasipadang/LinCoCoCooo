//
//  AvailabilityEndpoint.swift
//  Coco
//
//  Created by Claude on 26/08/25.
//

import Foundation

enum AvailabilityEndpoint: EndpointProtocol {
    case getAvailability
    
    var path: String {
        switch self {
        case .getAvailability:
            return "rpc/get_availability"
        }
    }
}