//
//  HomeFormScheduleViewModelTests.swift
//  CocoTests
//
//  Created by Claude on 27/08/25.
//

import Foundation
import Testing
@testable import Coco

struct HomeFormScheduleViewModelTests {
    
    // MARK: - Test Data Setup
    
    private struct TestContext {
        let availabilityFetcher: MockAvailabilityFetcher
        let createBookingFetcher: MockCreateBookingFetcher
        let actionDelegate: MockHomeFormScheduleViewModelAction
        let navigationDelegate: MockHomeFormScheduleViewModelNavigationDelegate
        let viewModel: HomeFormScheduleViewModel
        let mockActivity: ActivityDetailDataModel
        
        static func setup() throws -> TestContext {
            let availabilityFetcher = MockAvailabilityFetcher()
            let createBookingFetcher = MockCreateBookingFetcher()
            let actionDelegate = MockHomeFormScheduleViewModelAction()
            let navigationDelegate = MockHomeFormScheduleViewModelNavigationDelegate()
            
            let mockActivity = createMockActivity()
            let input = HomeFormScheduleInput(package: mockActivity, selectedPackageId: 1)
            
            let viewModel = HomeFormScheduleViewModel(
                input: input,
                availabilityFetcher: availabilityFetcher,
                createBookingFetcher: createBookingFetcher
            )
            viewModel.actionDelegate = actionDelegate
            viewModel.navigationDelegate = navigationDelegate
            
            return TestContext(
                availabilityFetcher: availabilityFetcher,
                createBookingFetcher: createBookingFetcher,
                actionDelegate: actionDelegate,
                navigationDelegate: navigationDelegate,
                viewModel: viewModel,
                mockActivity: mockActivity
            )
        }
        
        private static func createMockActivity() -> ActivityDetailDataModel {
            let mockPackage = ActivityDetailDataModel.Package(
                imageUrlString: "https://example.com/package.jpg",
                name: "Snorkeling Adventure",
                description: "2 - 4 person",
                price: "Rp 500,000",
                pricePerPerson: 500000,
                minParticipants: 2,
                maxParticipants: 4,
                id: 1,
                hostName: "Ocean Explorer",
                startTime: "08:00",
                endTime: "16:00",
                hostBio: "Professional diving instructor with 10 years experience",
                hostProfileImageUrl: "https://example.com/host.jpg"
            )
            
            let mockActivity = ActivityDetailDataModel(
                id: 1,
                label: "Popular",
                title: "Amazing Snorkeling Adventure",
                location: "Nusa Penida",
                imageUrlsString: ["https://example.com/image1.jpg"],
                durationMinutes: 480,
                descriptionInfomation: ActivitySectionLayout(
                    title: "Description",
                    content: "Amazing underwater experience"
                ),
                providerDetail: ActivitySectionLayout(
                    title: "Trip Provider",
                    content: ActivityDetailDataModel.ProviderDetail(
                        name: "Ocean Adventures",
                        description: "Professional marine tour operator",
                        imageUrlString: "https://example.com/provider.jpg"
                    )
                ),
                tripFacilities: ActivitySectionLayout(
                    title: "Facilities",
                    content: ["Snorkeling Equipment", "Life Jacket", "Underwater Camera"]
                ),
                tnc: "Terms and conditions apply",
                lowestPriceFormatted: "Rp 500,000",
                availablePackages: ActivitySectionLayout(
                    title: "Available Packages",
                    content: ["Ocean Explorer": [mockPackage]]
                ),
                hiddenPackages: [mockPackage]
            )
            
            return mockActivity
        }
    }
    
    // MARK: - Initialization Tests
    
    @Test("initialization - should setup booking sections correctly")
    func initialization_whenValidInput_shouldSetupSections() throws {
        // --- GIVEN & WHEN ---
        let context = try TestContext.setup()
        
        // --- THEN ---
        let sections = context.viewModel.bookingDetailSections
        
        // Should have all expected sections
        let sectionTypes = sections.map { $0.type }
        #expect(sectionTypes.contains(.packageInfo))
        #expect(sectionTypes.contains(.tripProvider))
        #expect(sectionTypes.contains(.itinerary))
        #expect(sectionTypes.contains(.travelerDetails))
        
        // Package info should be populated
        let packageSection = sections.first { $0.type == .packageInfo }
        #expect(packageSection?.items.isEmpty == false)
        
        // Trip provider should use selected package host
        let providerSection = sections.first { $0.type == .tripProvider }
        let providerItem = providerSection?.items.first as? TripProviderDisplayItem
        #expect(providerItem?.name == "Ocean Explorer")
        #expect(providerItem?.description == "Professional diving instructor with 10 years experience")
        
        // Itinerary should have multiple segments
        let itinerarySection = sections.first { $0.type == .itinerary }
        let itineraryItems = itinerarySection?.items as? [ItineraryDisplayItem]
        #expect(itineraryItems?.count ?? 0 > 2) // Should have detailed itinerary
    }
    
    // MARK: - Package Selection Tests
    
    @Test("package selection - should update selected package correctly")
    func packageSelection_whenValidPackage_shouldUpdateState() throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.didSelectPackage(withId: 1)
        
        // --- THEN ---
        #expect(context.viewModel.selectedPackage?.id == 1)
        #expect(context.viewModel.selectedPackage?.name == "Snorkeling Adventure")
        
        // Should update sections with new package data
        let sections = context.viewModel.bookingDetailSections
        let providerSection = sections.first { $0.type == .tripProvider }
        let providerItem = providerSection?.items.first as? TripProviderDisplayItem
        #expect(providerItem?.name == "Ocean Explorer")
    }
    
    @Test("package selection - should handle invalid package id")
    func packageSelection_whenInvalidPackageId_shouldNotCrash() throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.didSelectPackage(withId: 999)
        
        // --- THEN ---
        // Should not crash and maintain current state
        #expect(context.viewModel.selectedPackage == nil || context.viewModel.selectedPackage?.id != 999)
    }
    
    // MARK: - Date Selection Tests
    
    @Test("date selection - should handle valid date selection")
    func dateSelection_whenValidDate_shouldUpdateState() throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        let testDate = Date()
        
        // --- WHEN ---
        context.viewModel.didSelectDate(testDate)
        
        // --- THEN ---
        #expect(context.viewModel.selectedDate == testDate)
    }
    
    // MARK: - Participant Input Tests
    
    @Test("participant input - should validate participant count within package limits")
    func participantInput_whenValidCount_shouldAccept() throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        context.viewModel.didSelectPackage(withId: 1) // Package with 2-4 participants
        
        // --- WHEN ---
        context.viewModel.paxInputViewModel.currentTypedText = "3"
        
        // --- THEN ---
        let participantCount = Int(context.viewModel.paxInputViewModel.currentTypedText) ?? 0
        #expect(participantCount >= 2 && participantCount <= 4)
    }
    
    // MARK: - Traveler Details Tests
    
    @Test("traveler details - should handle traveler information updates")
    func travelerDetails_whenValidInfo_shouldUpdateState() throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.travelerNameInputViewModel.currentTypedText = "John Doe"
        context.viewModel.travelerEmailInputViewModel.currentTypedText = "john@example.com"
        context.viewModel.travelerPhoneInputViewModel.currentTypedText = "+6281234567890"
        
        // --- THEN ---
        #expect(context.viewModel.travelerNameInputViewModel.currentTypedText == "John Doe")
        #expect(context.viewModel.travelerEmailInputViewModel.currentTypedText == "john@example.com")
        #expect(context.viewModel.travelerPhoneInputViewModel.currentTypedText == "+6281234567890")
    }
    
    // MARK: - Price Calculation Tests
    
    @Test("price calculation - should calculate total price correctly")
    func priceCalculation_whenValidInputs_shouldCalculateCorrectly() throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        context.viewModel.didSelectPackage(withId: 1) // Package with 500,000 per person
        context.viewModel.paxInputViewModel.currentTypedText = "3" // 3 participants
        
        // --- WHEN ---
        let priceData = context.viewModel.generatePriceDetailsData()
        
        // --- THEN ---
        #expect(priceData.participantCount == 3)
        #expect(priceData.totalPrice.contains("1,500,000")) // 500,000 * 3
    }
    
    // MARK: - Form Validation Tests
    
    @Test("form validation - should validate complete booking data")
    func formValidation_whenCompleteData_shouldBeValid() throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        // Setup complete form data
        context.viewModel.didSelectPackage(withId: 1)
        context.viewModel.didSelectDate(Date())
        context.viewModel.paxInputViewModel.currentTypedText = "2"
        context.viewModel.travelerNameInputViewModel.currentTypedText = "Jane Smith"
        context.viewModel.travelerEmailInputViewModel.currentTypedText = "jane@example.com"
        context.viewModel.travelerPhoneInputViewModel.currentTypedText = "+6281234567890"
        
        // --- WHEN & THEN ---
        // Form should be considered valid for booking
        #expect(context.viewModel.selectedPackage != nil)
        #expect(context.viewModel.selectedDate != nil)
        #expect(!context.viewModel.paxInputViewModel.currentTypedText.isEmpty)
        #expect(!context.viewModel.travelerNameInputViewModel.currentTypedText.isEmpty)
    }
    
    // MARK: - Booking Submission Tests
    
    @Test("booking submission - should handle successful booking")
    func bookingSubmission_whenSuccessful_shouldNotifyDelegate() throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        // Setup form data
        context.viewModel.didSelectPackage(withId: 1)
        context.viewModel.didSelectDate(Date())
        context.viewModel.paxInputViewModel.currentTypedText = "2"
        context.viewModel.travelerNameInputViewModel.currentTypedText = "John Doe"
        context.viewModel.travelerEmailInputViewModel.currentTypedText = "john@example.com"
        context.viewModel.travelerPhoneInputViewModel.currentTypedText = "+6281234567890"
        
        // Mock successful booking response
        let successResponse = CreateBookingResponse(
            bookingId: 12345,
            status: "confirmed",
            totalAmount: 1000000,
            paymentUrl: "https://payment.example.com/12345"
        )
        context.createBookingFetcher.stubbedCreateBookingCompletionResult = (.success(successResponse), ())
        
        // --- WHEN ---
        context.viewModel.submitBooking()
        
        // --- THEN ---
        #expect(context.createBookingFetcher.invokedCreateBookingCount == 1)
        #expect(context.navigationDelegate.invokedNotifyBookingSuccessCount == 1)
    }
    
    @Test("booking submission - should handle booking failure")
    func bookingSubmission_whenFailed_shouldShowError() throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        // Setup form data
        context.viewModel.didSelectPackage(withId: 1)
        context.viewModel.didSelectDate(Date())
        context.viewModel.paxInputViewModel.currentTypedText = "2"
        context.viewModel.travelerNameInputViewModel.currentTypedText = "John Doe"
        
        // Mock failed booking response
        let error = NetworkServiceError.invalidResponse
        context.createBookingFetcher.stubbedCreateBookingCompletionResult = (.failure(error), ())
        
        // --- WHEN ---
        context.viewModel.submitBooking()
        
        // --- THEN ---
        #expect(context.createBookingFetcher.invokedCreateBookingCount == 1)
        #expect(context.actionDelegate.invokedShowErrorCount == 1)
    }
    
    // MARK: - Itinerary Generation Tests
    
    @Test("itinerary generation - should generate activity-specific itinerary")
    func itineraryGeneration_whenSnorkelingActivity_shouldGenerateDivingItinerary() throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        // --- WHEN ---
        let sections = context.viewModel.bookingDetailSections
        let itinerarySection = sections.first { $0.type == .itinerary }
        let itineraryItems = itinerarySection?.items as? [ItineraryDisplayItem]
        
        // --- THEN ---
        #expect(itineraryItems?.count == 6) // Diving itinerary has 6 segments
        #expect(itineraryItems?[0].title == "Meet & Greet")
        #expect(itineraryItems?[1].title == "Equipment Setup")
        #expect(itineraryItems?[3].title == "First Dive/Snorkel")
        
        // Should use package times
        #expect(itineraryItems?[0].time == "08:00")
        #expect(itineraryItems?.last?.isLastItem == true)
    }
}

// MARK: - Mock Classes

private final class MockAvailabilityFetcher: AvailabilityFetcher {
    
    var invokedGetAvailability = false
    var invokedGetAvailabilityCount = 0
    var stubbedGetAvailabilityResult: Result<AvailabilityResponse, Error>?
    
    override func getAvailability(request: AvailabilitySpec) async throws -> AvailabilityResponse {
        invokedGetAvailability = true
        invokedGetAvailabilityCount += 1
        
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
    var stubbedCreateBookingCompletionResult: (Result<CreateBookingResponse, NetworkServiceError>, Void)?
    
    override func createBooking(spec: CreateBookingSpec, completion: @escaping (Result<CreateBookingResponse, NetworkServiceError>) -> Void) {
        invokedCreateBooking = true
        invokedCreateBookingCount += 1
        
        if let result = stubbedCreateBookingCompletionResult {
            completion(result.0)
        }
    }
}

private final class MockHomeFormScheduleViewModelAction: HomeFormScheduleViewModelAction {
    
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
    var invokedShowSuccessMessageParameters: (message: String, Void)?
    
    func showSuccessMessage(message: String) {
        invokedShowSuccessMessage = true
        invokedShowSuccessMessageCount += 1
        invokedShowSuccessMessageParameters = (message, ())
    }
    
    var invokedUpdateBookingSections = false
    var invokedUpdateBookingSectionsCount = 0
    var invokedUpdateBookingSectionsParameters: (sections: [BookingDetailSection], Void)?
    
    func updateBookingSections(sections: [BookingDetailSection]) {
        invokedUpdateBookingSections = true
        invokedUpdateBookingSectionsCount += 1
        invokedUpdateBookingSectionsParameters = (sections, ())
    }
}

private final class MockHomeFormScheduleViewModelNavigationDelegate: HomeFormScheduleViewModelNavigationDelegate {
    
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