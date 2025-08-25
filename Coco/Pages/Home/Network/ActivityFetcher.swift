//
//  ActivityFetcher.swift
//  Coco
//
//  Created by Jackie Leonardy on 01/07/25.
//

import Foundation

protocol ActivityFetcherProtocol: AnyObject {
    func fetchActivity(
        request: ActivitySearchRequest,
        completion: @escaping (Result<ActivityModelArray, NetworkServiceError>) -> Void
    )
    func fetchTopDestination(
        completion: @escaping (Result<ActivityTopDestinationModelArray, NetworkServiceError>) -> Void
    )
    func fetchPackageDetail(
        packageId: Int,
        completion: @escaping (Result<ActivityPackage, NetworkServiceError>) -> Void
    )
}

final class ActivityFetcher: ActivityFetcherProtocol {
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchPackageDetail(
        packageId: Int,
        completion: @escaping (Result<ActivityPackage, NetworkServiceError>) -> Void
    ) {
        networkService.request(
            urlString: ActivityEndpoint.packageDetail(id: packageId).urlString,
            method: .get,
            parameters: [:],
            headers: [
                "Accept": "application/vnd.pgrst.object+json"
            ],
            body: nil,
            completion: completion
        )
    }
    
    func fetchActivity(
        request: ActivitySearchRequest,
        completion: @escaping (Result<ActivityModelArray, NetworkServiceError>) -> Void
    ) {
        networkService.request(
            urlString: ActivityEndpoint.all.urlString,
            method: .post,
            parameters: [:],
            headers: [:],
            body: request,
            completion: completion
        )
    }
    
    func fetchTopDestination(
        completion: @escaping (Result<ActivityTopDestinationModelArray, NetworkServiceError>) -> Void
    ) {
        networkService.request(
            urlString: ActivityEndpoint.topDestination.urlString,
            method: .post,
            parameters: [:],
            headers: [:],
            body: nil,
            completion: completion
        )
    }
    
    private let networkService: NetworkServiceProtocol
}
