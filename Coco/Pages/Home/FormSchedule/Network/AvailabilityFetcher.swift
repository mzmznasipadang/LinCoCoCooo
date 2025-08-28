//
//  AvailabilityFetcher.swift
//  Coco
//
//  Created by Claude on 26/08/25.
//

import Foundation

protocol AvailabilityFetcherProtocol {
    func getAvailability(request: AvailabilitySpec) async throws -> AvailabilityResponse
}

final class AvailabilityFetcher: AvailabilityFetcherProtocol {
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func getAvailability(request: AvailabilitySpec) async throws -> AvailabilityResponse {
        do {
            // Create query parameters for filtering
            let parameters = [
                "package_id": "eq.\(request.packageId)",
                "date": "eq.\(request.date)",
                "select": "*"
            ]
            
            // Since API returns an array, we'll need to get the first result
            let responses: [AvailabilityResponse] = try await networkService.request(
                urlString: AvailabilityEndpoint.getAvailability.urlString,
                method: .get,
                parameters: parameters,
                headers: [:],
                body: nil as JSONEncodable?
            )
            
            // Return the first matching availability or create a default one
            if let first = responses.first {
                return first
            } else {
                // No availability found - create a response with 0 slots
                return AvailabilityResponse(
                    id: 0,
                    packageId: request.packageId,
                    date: request.date,
                    startTime: "09:00:00",
                    endTime: "17:00:00",
                    availableSlots: 0
                )
            }
        } catch let NetworkServiceError.requestFailedWithMessage(error, data) {
            throw APIError(data: data, response: nil, underlying: error)
        } catch let NetworkServiceError.statusCode(status) {
            throw APIError(data: nil, response: nil, underlying: NetworkServiceError.statusCode(status))
        } catch {
            throw error
        }
    }
    
    private let networkService: NetworkServiceProtocol
}
