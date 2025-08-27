//
//  CreateBookingFetcherTests.swift
//  CocoTests
//
//  Created by Claude on 27/08/25.
//

import Foundation
import Testing
@testable import Coco

struct CreateBookingFetcherTests {
    
    // MARK: - Test Data Setup
    
    private struct TestData {
        static let validBookingSpec = CreateBookingSpec(
            activityId: 1,
            packageId: 1,
            bookingDate: "2025-08-28",
            participantCount: 2,
            totalAmount: 1000000,
            travelerName: "John Doe",
            travelerEmail: "john@example.com",
            travelerPhone: "+6281234567890"
        )
        
        static let validBookingResponse = CreateBookingResponse(
            bookingId: 12345,
            status: "confirmed",
            totalAmount: 1000000,
            paymentUrl: "https://payment.example.com/12345"
        )
        
        static let mockJSONResponse = """
        {
            "booking_id": 12345,
            "status": "confirmed",
            "total_amount": 1000000,
            "payment_url": "https://payment.example.com/12345"
        }
        """.data(using: .utf8)!
    }
    
    // MARK: - Initialization Tests
    
    @Test("initialization - should create fetcher with correct network service")
    func initialization_whenCreated_shouldHaveNetworkService() throws {
        // --- GIVEN & WHEN ---
        let fetcher = CreateBookingFetcher()
        
        // --- THEN ---
        #expect(fetcher.networkService != nil)
    }
    
    // MARK: - Successful Booking Tests
    
    @Test("create booking - should handle successful booking response")
    func createBooking_whenSuccessful_shouldReturnBookingResponse() async throws {
        // --- GIVEN ---
        let fetcher = CreateBookingFetcher()
        let mockNetworkService = MockNetworkService()
        fetcher.networkService = mockNetworkService
        
        // Mock successful response
        mockNetworkService.stubbedRequestResult = .success(TestData.mockJSONResponse)
        
        var capturedResult: Result<CreateBookingResponse, NetworkServiceError>?
        let expectation = MockExpectation()
        
        // --- WHEN ---
        fetcher.createBooking(spec: TestData.validBookingSpec) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Wait for async completion
        try await expectation.wait()
        
        // --- THEN ---
        guard case .success(let response) = capturedResult else {
            throw TestError.unexpectedResult("Expected success result")
        }
        
        #expect(response.bookingId == 12345)
        #expect(response.status == "confirmed")
        #expect(response.totalAmount == 1000000)
        #expect(response.paymentUrl == "https://payment.example.com/12345")
        
        // Verify network call was made correctly
        #expect(mockNetworkService.invokedRequestCount == 1)
        let requestParam = mockNetworkService.invokedRequestParameters
        #expect(requestParam?.endpoint.path.contains("bookings") == true)
        #expect(requestParam?.endpoint.method == .post)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("create booking - should handle network error")
    func createBooking_whenNetworkError_shouldReturnError() async throws {
        // --- GIVEN ---
        let fetcher = CreateBookingFetcher()
        let mockNetworkService = MockNetworkService()
        fetcher.networkService = mockNetworkService
        
        // Mock network error
        mockNetworkService.stubbedRequestResult = .failure(.noInternetConnection)
        
        var capturedResult: Result<CreateBookingResponse, NetworkServiceError>?
        let expectation = MockExpectation()
        
        // --- WHEN ---
        fetcher.createBooking(spec: TestData.validBookingSpec) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        try await expectation.wait()
        
        // --- THEN ---
        guard case .failure(let error) = capturedResult else {
            throw TestError.unexpectedResult("Expected failure result")
        }
        
        #expect(error == .noInternetConnection)
    }
    
    @Test("create booking - should handle invalid JSON response")
    func createBooking_whenInvalidJSON_shouldReturnDecodingError() async throws {
        // --- GIVEN ---
        let fetcher = CreateBookingFetcher()
        let mockNetworkService = MockNetworkService()
        fetcher.networkService = mockNetworkService
        
        // Mock invalid JSON response
        let invalidJSON = "{ invalid json }".data(using: .utf8)!
        mockNetworkService.stubbedRequestResult = .success(invalidJSON)
        
        var capturedResult: Result<CreateBookingResponse, NetworkServiceError>?
        let expectation = MockExpectation()
        
        // --- WHEN ---
        fetcher.createBooking(spec: TestData.validBookingSpec) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        try await expectation.wait()
        
        // --- THEN ---
        guard case .failure(let error) = capturedResult else {
            throw TestError.unexpectedResult("Expected failure result")
        }
        
        #expect(error == .decodingError)
    }
    
    // MARK: - Request Validation Tests
    
    @Test("create booking - should send correct request parameters")
    func createBooking_whenCalled_shouldSendCorrectParameters() async throws {
        // --- GIVEN ---
        let fetcher = CreateBookingFetcher()
        let mockNetworkService = MockNetworkService()
        fetcher.networkService = mockNetworkService
        
        mockNetworkService.stubbedRequestResult = .success(TestData.mockJSONResponse)
        
        let customSpec = CreateBookingSpec(
            activityId: 99,
            packageId: 88,
            bookingDate: "2025-12-25",
            participantCount: 5,
            totalAmount: 2500000,
            travelerName: "Jane Smith",
            travelerEmail: "jane@test.com",
            travelerPhone: "+6289876543210"
        )
        
        var capturedResult: Result<CreateBookingResponse, NetworkServiceError>?
        let expectation = MockExpectation()
        
        // --- WHEN ---
        fetcher.createBooking(spec: customSpec) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        try await expectation.wait()
        
        // --- THEN ---
        #expect(mockNetworkService.invokedRequestCount == 1)
        let requestParam = mockNetworkService.invokedRequestParameters
        
        // Verify endpoint configuration
        let endpoint = requestParam?.endpoint as? CreateBookingEndpoint
        #expect(endpoint?.method == .post)
        #expect(endpoint?.path.contains("bookings") == true)
        
        // Verify request body contains spec data
        let bodyData = requestParam?.endpoint.body
        #expect(bodyData != nil)
        
        // Parse body and verify content
        if let bodyData = bodyData,
           let bodyDict = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any] {
            #expect(bodyDict["activity_id"] as? Int == 99)
            #expect(bodyDict["package_id"] as? Int == 88)
            #expect(bodyDict["booking_date"] as? String == "2025-12-25")
            #expect(bodyDict["participant_count"] as? Int == 5)
            #expect(bodyDict["total_amount"] as? Int == 2500000)
            #expect(bodyDict["traveler_name"] as? String == "Jane Smith")
            #expect(bodyDict["traveler_email"] as? String == "jane@test.com")
            #expect(bodyDict["traveler_phone"] as? String == "+6289876543210")
        }
    }
    
    // MARK: - Response Parsing Tests
    
    @Test("create booking - should parse different response formats correctly")
    func createBooking_whenDifferentResponseFormats_shouldParseCorrectly() async throws {
        // --- GIVEN ---
        let fetcher = CreateBookingFetcher()
        let mockNetworkService = MockNetworkService()
        fetcher.networkService = mockNetworkService
        
        let testCases: [(String, (CreateBookingResponse) -> Bool)] = [
            // Standard response
            ("""
            {
                "booking_id": 54321,
                "status": "pending",
                "total_amount": 750000,
                "payment_url": "https://pay.example.com/54321"
            }
            """, { response in
                response.bookingId == 54321 && 
                response.status == "pending" && 
                response.totalAmount == 750000 &&
                response.paymentUrl == "https://pay.example.com/54321"
            }),
            
            // Response without payment URL (optional field)
            ("""
            {
                "booking_id": 99999,
                "status": "confirmed",
                "total_amount": 1500000
            }
            """, { response in
                response.bookingId == 99999 && 
                response.status == "confirmed" && 
                response.totalAmount == 1500000 &&
                response.paymentUrl == nil
            })
        ]
        
        for (jsonString, validation) in testCases {
            let jsonData = jsonString.data(using: .utf8)!
            mockNetworkService.stubbedRequestResult = .success(jsonData)
            
            var capturedResult: Result<CreateBookingResponse, NetworkServiceError>?
            let expectation = MockExpectation()
            
            // --- WHEN ---
            fetcher.createBooking(spec: TestData.validBookingSpec) { result in
                capturedResult = result
                expectation.fulfill()
            }
            
            try await expectation.wait()
            
            // --- THEN ---
            guard case .success(let response) = capturedResult else {
                throw TestError.unexpectedResult("Expected success result for: \(jsonString)")
            }
            
            #expect(validation(response))
        }
    }
}

// MARK: - Test Utilities

private enum TestError: Error {
    case unexpectedResult(String)
    case timeoutError
}

private class MockExpectation {
    private var isFulfilled = false
    
    func fulfill() {
        isFulfilled = true
    }
    
    func wait() async throws {
        let startTime = Date()
        let timeout: TimeInterval = 1.0
        
        while !isFulfilled {
            if Date().timeIntervalSince(startTime) > timeout {
                throw TestError.timeoutError
            }
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
    }
}

private final class MockNetworkService: NetworkService {
    
    var invokedRequest = false
    var invokedRequestCount = 0
    var invokedRequestParameters: (endpoint: Endpoint, Void)?
    var stubbedRequestResult: Result<Data, NetworkServiceError>!
    
    override func request<T: Endpoint>(
        endpoint: T,
        completion: @escaping (Result<Data, NetworkServiceError>) -> Void
    ) {
        invokedRequest = true
        invokedRequestCount += 1
        invokedRequestParameters = (endpoint, ())
        
        // Simulate async network call
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            completion(self.stubbedRequestResult)
        }
    }
}