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
            return try await networkService.request(
                urlString: AvailabilityEndpoint.getAvailability.urlString,
                method: .post,
                parameters: [:],
                headers: [:],
                body: request
            )
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