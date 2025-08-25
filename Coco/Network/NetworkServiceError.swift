//
//  NetworkServiceError.swift
//  Coco
//
//  Created by Jackie Leonardy on 30/06/25.
//

import Foundation

enum NetworkServiceError: Error {
    case invalidURL
    case bodyParsingFailed
    case requestFailed(Error)
    case requestFailedWithMessage(error: Error, data: Data?)
    case invalidResponse
    case decodingFailed(Error)
    case statusCode(Int)
    case noInternetConnection
}
