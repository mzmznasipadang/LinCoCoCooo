//
//  BookingIntegrationTests.swift
//  CocoTests
//
//  Created by Claude on 27/08/25.
//

import Foundation
import Testing
@testable import Coco

/// Integration tests for the complete booking flow
struct BookingIntegrationTests {
    
    // MARK: - Complete Booking Flow Tests
    
    @Test("complete booking flow - diving activity with successful booking")
    func completeBookingFlow_divingActivity_shouldCompleteSuccessfully() async throws {
        // --- GIVEN ---
        let mockActivity = TestHelpers.createMockActivityDetailDataModel(
            id: 1,
            title: "Professional Scuba Diving Experience",
            location: "Nusa Penida Marine Park"
        )
        
        let input = HomeFormScheduleInput(package: mockActivity, selectedPackageId: 1)
        
        let availabilityFetcher = MockAvailabilityFetcher()
        let createBookingFetcher = MockCreateBookingFetcher()
        let actionDelegate = MockBookingActionDelegate()
        let navigationDelegate = MockBookingNavigationDelegate()
        
        let viewModel = HomeFormScheduleViewModel(
            input: input,
            availabilityFetcher: availabilityFetcher,
            createBookingFetcher: createBookingFetcher
        )
        viewModel.actionDelegate = actionDelegate
        viewModel.navigationDelegate = navigationDelegate
        
        // Setup successful responses
        availabilityFetcher.stubbedGetAvailabilityResult = .success(
            TestHelpers.createMockAvailabilityResponse()
        )
        createBookingFetcher.stubbedCreateBookingResult = .success(
            TestHelpers.createMockCreateBookingResponse(bookingId: 67890)
        )
        
        // --- WHEN ---
        // 1. Initialize and verify sections are created
        let initialSections = viewModel.bookingDetailSections
        
        // 2. Select package
        viewModel.didSelectPackage(withId: 1)
        
        // 3. Select date
        let bookingDate = TestHelpers.createDate(year: 2025, month: 8, day: 30)
        viewModel.didSelectDate(bookingDate)
        
        // 4. Fill in participant count
        viewModel.paxInputViewModel.currentTypedText = "3"
        
        // 5. Fill in traveler details
        viewModel.travelerNameInputViewModel.currentTypedText = "Alice Johnson"
        viewModel.travelerEmailInputViewModel.currentTypedText = "alice@example.com"
        viewModel.travelerPhoneInputViewModel.currentTypedText = "+6281234567890"
        
        // 6. Submit booking
        let expectation = TestHelpers.AsyncExpectation()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            viewModel.submitBooking()
            expectation.fulfill()
        }
        
        try await expectation.wait()
        
        // --- THEN ---
        // Verify initial setup
        TestAssertions.assertBookingSection(initialSections[0], type: .packageInfo)
        TestAssertions.assertBookingSection(initialSections[1], type: .tripProvider)
        TestAssertions.assertBookingSection(initialSections[2], type: .itinerary)
        TestAssertions.assertBookingSection(initialSections[3], type: .travelerDetails)
        
        // Verify itinerary is diving-specific (6 segments)
        let itinerarySection = initialSections.first { $0.type == .itinerary }
        let itineraryItems = itinerarySection?.items as? [ItineraryDisplayItem]
        TestAssertions.assertItinerary(itineraryItems ?? [], expectedCount: 6)
        
        // Verify trip provider uses correct host data
        let providerSection = initialSections.first { $0.type == .tripProvider }
        let providerItem = providerSection?.items.first as? TripProviderDisplayItem
        TestAssertions.assertTripProvider(providerItem!, name: "Test Host")
        
        // Verify booking was submitted
        #expect(createBookingFetcher.invokedCreateBookingCount == 1)
        
        // Verify success navigation was called
        #expect(navigationDelegate.invokedNotifyBookingSuccessCount == 1)
        #expect(navigationDelegate.invokedNotifyBookingSuccessParameters?.bookingId == 67890)
        
        // Verify price calculation
        let priceData = viewModel.generatePriceDetailsData()
        #expect(priceData.participantCount == 3)
        #expect(priceData.travelerName == "Alice Johnson")
        #expect(priceData.totalPrice.contains("1,500,000")) // 500,000 * 3
    }
    
    @Test("complete booking flow - hiking activity with different parameters")
    func completeBookingFlow_hikingActivity_shouldGenerateCorrectItinerary() throws {
        // --- GIVEN ---
        let hikingPackage = TestHelpers.createMockPackage(
            id: 2,
            name: "Mount Batur Sunrise Trek",
            hostName: "Mountain Guides Indonesia",
            pricePerPerson: 300000,
            startTime: "03:00",
            endTime: "11:00"
        )
        
        let mockActivity = ActivityDetailDataModel(
            id: 2,
            label: "Adventure",
            title: "Mount Batur Hiking Experience", // Keywords for hiking detection
            location: "Mount Batur, Bali",
            imageUrlsString: ["https://example.com/mountain.jpg"],
            durationMinutes: 480,
            descriptionInfomation: ActivitySectionLayout(
                title: "Description",
                content: "Challenging mountain trek"
            ),
            providerDetail: ActivitySectionLayout(
                title: "Trip Provider",
                content: ActivityDetailDataModel.ProviderDetail(
                    name: "Mountain Adventures",
                    description: "Expert mountain guides",
                    imageUrlString: "https://example.com/mountain-guide.jpg"
                )
            ),
            tripFacilities: ActivitySectionLayout(
                title: "Facilities",
                content: ["Hiking Equipment", "Headlamp", "Guide"]
            ),
            tnc: "Mountain climbing terms",
            lowestPriceFormatted: "Rp 300,000",
            availablePackages: ActivitySectionLayout(
                title: "Available Packages",
                content: ["Mountain Guides Indonesia": [hikingPackage]]
            ),
            hiddenPackages: [hikingPackage]
        )
        
        let input = HomeFormScheduleInput(package: mockActivity, selectedPackageId: 2)
        let viewModel = HomeFormScheduleViewModel(
            input: input,
            availabilityFetcher: MockAvailabilityFetcher(),
            createBookingFetcher: MockCreateBookingFetcher()
        )
        
        // --- WHEN ---
        viewModel.didSelectPackage(withId: 2)
        let sections = viewModel.bookingDetailSections
        
        // --- THEN ---
        // Verify hiking itinerary (5 segments)
        let itinerarySection = sections.first { $0.type == .itinerary }
        let itineraryItems = itinerarySection?.items as? [ItineraryDisplayItem]
        
        TestAssertions.assertItinerary(itineraryItems ?? [], expectedCount: 5)
        
        // Verify hiking-specific content
        #expect(itineraryItems?[0].title == "Trail Preparation")
        #expect(itineraryItems?[1].title == "Trail Ascent")
        #expect(itineraryItems?[2].title == "Summit/Viewpoint")
        #expect(itineraryItems?[3].title == "Nature Exploration")
        #expect(itineraryItems?[4].title == "Descent & Return")
        
        // Verify early morning start time
        #expect(itineraryItems?[0].time == "03:00")
        
        // Verify provider information
        let providerSection = sections.first { $0.type == .tripProvider }
        let providerItem = providerSection?.items.first as? TripProviderDisplayItem
        TestAssertions.assertTripProvider(providerItem!, name: "Mountain Guides Indonesia")
    }
    
    @Test("booking error handling - network failure should show error")
    func bookingErrorHandling_whenNetworkFailure_shouldShowError() async throws {
        // --- GIVEN ---
        let mockActivity = TestHelpers.createMockActivityDetailDataModel()
        let input = HomeFormScheduleInput(package: mockActivity, selectedPackageId: 1)
        
        let createBookingFetcher = MockCreateBookingFetcher()
        let actionDelegate = MockBookingActionDelegate()
        
        let viewModel = HomeFormScheduleViewModel(
            input: input,
            availabilityFetcher: MockAvailabilityFetcher(),
            createBookingFetcher: createBookingFetcher
        )
        viewModel.actionDelegate = actionDelegate
        
        // Setup failure response
        createBookingFetcher.stubbedCreateBookingResult = .failure(.noInternetConnection)
        
        // Fill required form data
        viewModel.didSelectPackage(withId: 1)
        viewModel.didSelectDate(Date())
        viewModel.paxInputViewModel.currentTypedText = "2"
        viewModel.travelerNameInputViewModel.currentTypedText = "Test User"
        viewModel.travelerEmailInputViewModel.currentTypedText = "test@example.com"
        viewModel.travelerPhoneInputViewModel.currentTypedText = "+6281234567890"
        
        // --- WHEN ---
        let expectation = TestHelpers.AsyncExpectation()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            viewModel.submitBooking()
            expectation.fulfill()
        }
        
        try await expectation.wait()
        
        // --- THEN ---
        #expect(createBookingFetcher.invokedCreateBookingCount == 1)
        #expect(actionDelegate.invokedShowErrorCount == 1)
        #expect(actionDelegate.invokedShowErrorParameters?.message.contains("connection") == true)
    }
    
    @Test("form validation - incomplete data should prevent submission")
    func formValidation_whenIncompleteData_shouldPreventSubmission() throws {
        // --- GIVEN ---
        let mockActivity = TestHelpers.createMockActivityDetailDataModel()
        let input = HomeFormScheduleInput(package: mockActivity, selectedPackageId: 1)
        
        let createBookingFetcher = MockCreateBookingFetcher()
        let actionDelegate = MockBookingActionDelegate()
        
        let viewModel = HomeFormScheduleViewModel(
            input: input,
            availabilityFetcher: MockAvailabilityFetcher(),
            createBookingFetcher: createBookingFetcher
        )
        viewModel.actionDelegate = actionDelegate
        
        // --- WHEN ---
        // Only fill partial form data (missing traveler details)
        viewModel.didSelectPackage(withId: 1)
        viewModel.didSelectDate(Date())
        viewModel.paxInputViewModel.currentTypedText = "2"
        // Missing: traveler name, email, phone
        
        viewModel.submitBooking()
        
        // --- THEN ---
        // Should not submit booking with incomplete data
        #expect(createBookingFetcher.invokedCreateBookingCount == 0)
        #expect(actionDelegate.invokedShowErrorCount == 1)
    }
}

// MARK: - Mock Delegates

private final class MockBookingActionDelegate: HomeFormScheduleViewModelAction {
    
    var invokedShowError = false
    var invokedShowErrorCount = 0
    var invokedShowErrorParameters: (message: String, Void)?
    
    func showError(message: String) {
        invokedShowError = true
        invokedShowErrorCount += 1
        invokedShowErrorParameters = (message, ())
    }
    
    var invokedShowSuccessMessage = false
    var invokedShowSuccessMessageCount = 0
    
    func showSuccessMessage(message: String) {
        invokedShowSuccessMessage = true
        invokedShowSuccessMessageCount += 1
    }
    
    var invokedUpdateBookingSections = false
    var invokedUpdateBookingSectionsCount = 0
    
    func updateBookingSections(sections: [BookingDetailSection]) {
        invokedUpdateBookingSections = true
        invokedUpdateBookingSectionsCount += 1
    }
}

private final class MockBookingNavigationDelegate: HomeFormScheduleViewModelNavigationDelegate {
    
    var invokedNotifyBookingSuccess = false
    var invokedNotifyBookingSuccessCount = 0
    var invokedNotifyBookingSuccessParameters: (bookingId: Int, paymentUrl: String?)?
    
    func notifyBookingSuccess(bookingId: Int, paymentUrl: String?) {
        invokedNotifyBookingSuccess = true
        invokedNotifyBookingSuccessCount += 1
        invokedNotifyBookingSuccessParameters = (bookingId, paymentUrl)
    }
    
    var invokedNotifyBackToActivityDetail = false
    var invokedNotifyBackToActivityDetailCount = 0
    
    func notifyBackToActivityDetail() {
        invokedNotifyBackToActivityDetail = true
        invokedNotifyBackToActivityDetailCount += 1
    }
}

// MARK: - Mock Fetchers

private final class MockAvailabilityFetcher: AvailabilityFetcher {
    
    var invokedGetAvailability = false
    var invokedGetAvailabilityCount = 0
    var stubbedGetAvailabilityResult: Result<AvailabilityResponse, Error>?
    
    override func getAvailability(request: AvailabilitySpec) async throws -> AvailabilityResponse {
        invokedGetAvailability = true
        invokedGetAvailabilityCount += 1
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        
        if let result = stubbedGetAvailabilityResult {
            switch result {
            case .success(let response):
                return response
            case .failure(let error):
                throw error
            }
        }
        
        return TestHelpers.createMockAvailabilityResponse()
    }
}

private final class MockCreateBookingFetcher: CreateBookingFetcher {
    
    var invokedCreateBooking = false
    var invokedCreateBookingCount = 0
    var stubbedCreateBookingResult: Result<CreateBookingResponse, NetworkServiceError>?
    
    override func createBooking(spec: CreateBookingSpec, completion: @escaping (Result<CreateBookingResponse, NetworkServiceError>) -> Void) {
        invokedCreateBooking = true
        invokedCreateBookingCount += 1
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            if let result = self.stubbedCreateBookingResult {
                completion(result)
            }
        }
    }
}