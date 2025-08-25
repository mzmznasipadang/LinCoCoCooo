//
//  CreateBookingFetcher.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation

protocol CreateBookingFetcherProtocol {
    func createBooking(request: CreateBookingSpec) async throws -> CreateBookingResponse
}

final class CreateBookingFetcher: CreateBookingFetcherProtocol {
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func createBooking(request: CreateBookingSpec) async throws -> CreateBookingResponse {
        do {
            return try await networkService.request(
                urlString: CreateBookingEndpoint.create.urlString,
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
