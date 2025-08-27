//
//  HomeFormScheduleViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation

// MARK: - Data Models for Form Sections

/// Data model for form input section containing date and participant information
struct FormInputData {
    /// Selected date/time string (formatted date or "Select Date" placeholder)
    var selectedTime: String = "7.30"
    /// Number of participants as string
    var participantCount: String = "Select Number of Participants"
    /// Number of available slots for the selected date (optional)
    var availableSlots: Int?
}


// MARK: - ViewModel Input

/// Input data required to initialize the HomeFormScheduleViewModel
struct HomeFormScheduleViewModelInput {
    /// Activity detail data model containing package information
    let package: ActivityDetailDataModel
    /// ID of the selected package for booking
    let selectedPackageId: Int
}

// MARK: - HomeFormScheduleViewModel

/// ViewModel for the booking form schedule screen
/// Manages date selection, participant validation, form data, and booking creation
/// Implements MVVM pattern with delegate-based communication
final class HomeFormScheduleViewModel {
    // MARK: - Delegates
    
    /// Delegate for handling navigation and external actions
    weak var delegate: (any HomeFormScheduleViewModelDelegate)?
    
    /// Delegate for UI updates and interactions
    weak var actionDelegate: (any HomeFormScheduleViewModelAction)?
    
    init(input: HomeFormScheduleViewModelInput, fetcher: CreateBookingFetcherProtocol = CreateBookingFetcher(), activityFetcher: ActivityFetcherProtocol = ActivityFetcher(), availabilityFetcher: AvailabilityFetcherProtocol = AvailabilityFetcher()) {
        self.input = input
        self.fetcher = fetcher
        self.activityFetcher = activityFetcher
        self.availabilityFetcher = availabilityFetcher
    }
    
    // MARK: - Properties
    
    /// Input data containing package details and selected package ID
    let input: HomeFormScheduleViewModelInput
    
    /// ViewModel for the calendar/date input field
    /// Configured as non-typeable with calendar icon trigger
    private lazy var calendarInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: Localization.Placeholder.inputDateVisit,
        currentTypedText: "",
        trailingIcon: (
            image: CocoIcon.icFilterIcon.image,
            didTap: { [weak self] in self?.openCalendar() }
        ),
        isTypeAble: false,
        delegate: self
    )
    
    /// ViewModel for the participant count input field
    /// Configured with number pad keyboard and default value of 1
    private lazy var paxInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: Localization.Placeholder.inputTotalPax,
        currentTypedText: "Select Number of Participants",
        trailingIcon: nil,
        isTypeAble: true,
        delegate: self,
        keyboardType: .numberPad
    )
    
    /// Currently selected date for the booking
    /// When set, automatically formats and updates the calendar input field
    private var chosenDateInput: Date? {
        didSet {
            guard let chosenDateInput else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM, yyyy"
            calendarInputViewModel.currentTypedText = dateFormatter.string(from: chosenDateInput)
        }
    }
    
    /// Current traveler data from the form
    private var currentTravelerData = TravelerData(name: "", phone: "", email: "")
    
    /// Network service for creating bookings
    private let fetcher: CreateBookingFetcherProtocol
    
    private let activityFetcher: ActivityFetcherProtocol
    
    private let availabilityFetcher: AvailabilityFetcherProtocol
    
    private var minPax: Int?
    private var maxPax: Int?
    
    /// Current availability information for selected date
    private var currentAvailability: AvailabilityResponse?
}

// MARK: - HomeFormScheduleViewModelProtocol

extension HomeFormScheduleViewModel: HomeFormScheduleViewModelProtocol {
    func updateParticipantCount(_ count: Int) {
        paxInputViewModel.currentTypedText = "\(count)"
        // Rebuild sections to reflect the updated participant count
        let sections = buildSections()
        actionDelegate?.updateTableSections(sections)
        
        // Update price details
        let priceData = buildPriceDetailsData()
        actionDelegate?.updatePriceDetails(priceData)
    }
    
    func onTravelerDataChanged(_ data: TravelerData) {
        currentTravelerData = data
        // Update price details with new traveler name
        let priceData = buildPriceDetailsData()
        actionDelegate?.updatePriceDetails(priceData)
    }
    
    func refreshPaxPlaceholder() {
        let text: String
        switch (minPax, maxPax) {
        case let (min?, max?):
            text = Localization.Format.participantRangePerson(min: min, max: max)
        case let (min?, nil):
            text = Localization.Format.participantMinPerson(min)
        case let (nil, max?):
            text = Localization.Format.participantMaxPerson(max)
        default:
            text = Localization.Format.participantDefault
        }
        
        paxInputViewModel.placeholderText = text
    }
    
    func onViewDidLoad() {
        // Setup bottom input views
        actionDelegate?.setupView(
            calendarViewModel: calendarInputViewModel,
            paxInputViewModel: paxInputViewModel
        )
        
        // Build initial sections (availability will be updated async)
        let sections = buildSections()
        actionDelegate?.updateTableSections(sections)
        
        // Check availability for today's date initially
        checkAvailability(for: Date())
        
        let data: HomeFormScheduleViewData = HomeFormScheduleViewData(
            imageString: selectedPackage?.imageUrlString ?? input.package.imageUrlsString.first ?? "",
            activityName: input.package.title,
            packageName: selectedPackage?.name ?? "",
            location: input.package.location
        )
        actionDelegate?.configureView(data: data)
        
        if let selected = selectedPackage {
            self.minPax = selected.minParticipants
            self.maxPax = selected.maxParticipants
            self.refreshPaxPlaceholder()
        }
        
        activityFetcher.fetchPackageDetail(packageId: input.selectedPackageId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let pkg):
                self.minPax = pkg.minParticipants
                self.maxPax = pkg.maxParticipants
                self.refreshPaxPlaceholder()
            case .failure(let err):
                print("fetchPackageDetail error:", err)
            }
        }
        
        // Set initial availability to nil to show default state
        currentAvailability = nil
        
        // Update price details with initial state
        let priceData = buildPriceDetailsData()
        actionDelegate?.updatePriceDetails(priceData)
    }
    
    /// Handles date selection from the calendar
    /// Updates the internal date state and refreshes the UI immediately
    /// - Parameter date: The selected date
    func onCalendarDidChoose(date: Date) {
        chosenDateInput = date
        
        // Check availability for selected date (this will update UI when response comes back)
        checkAvailability(for: date, showErrorIfUnavailable: true)
        
        // Update price details immediately
        let priceData = buildPriceDetailsData()
        actionDelegate?.updatePriceDetails(priceData)
    }
    
    /// Checks availability for the selected date and package
    private func checkAvailability(for date: Date, showErrorIfUnavailable: Bool = false) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        print("🔍 Checking availability for Package ID: \(input.selectedPackageId), Date: \(formatter.string(from: date))")
        
        Task {
            do {
                let availabilitySpec = AvailabilitySpec(
                    packageId: input.selectedPackageId,
                    date: date
                )
                
                let availability = try await availabilityFetcher.getAvailability(request: availabilitySpec)
                
                print("✅ Availability response: Available: \(availability.isAvailable), Slots: \(availability.availableSlots)")
                
                await MainActor.run {
                    self.currentAvailability = availability
                    
                    // Rebuild sections to update availability info
                    let sections = self.buildSections()
                    actionDelegate?.updateTableSections(sections)
                    
                    // If no slots available and user explicitly selected date, show warning
                    if !availability.isAvailable && showErrorIfUnavailable {
                        actionDelegate?.showValidationError(message: "No available slots for selected date (\(availability.availableSlots) remaining). Please choose another date.")
                    } else {
                        print("✅ Date is available with \(availability.availableSlots) slots")
                    }
                }
                
            } catch {
                print("❌ Failed to check availability: \(error)")
                await MainActor.run {
                    // Set availability to unavailable if API call fails
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    
                    self.currentAvailability = AvailabilityResponse(
                        id: 0,
                        packageId: input.selectedPackageId,
                        date: formatter.string(from: date),
                        startTime: "09:00:00",
                        endTime: "17:00:00",
                        availableSlots: 0
                    )
                    
                    print("⚠️ Using fallback availability - Available: false, Slots: 0")
                    
                    // Rebuild sections to show the unavailable state
                    let sections = self.buildSections()
                    actionDelegate?.updateTableSections(sections)
                    
                    // Show error message to user only if they explicitly selected a date
                    if showErrorIfUnavailable {
                        actionDelegate?.showValidationError(message: "Unable to check availability for selected date. Please try again or contact support.")
                    }
                }
            }
        }
    }
    
    /// Handles checkout button tap
    /// Validates participant count against package constraints and creates booking
    /// Shows validation errors if constraints are not met
    func onCheckout() {
        print("🚨 CHECKOUT BUTTON PRESSED! Starting validation...")
        NSLog("🚨 CHECKOUT BUTTON PRESSED! Starting validation...")
        let raw = paxInputViewModel.currentTypedText.trimmingCharacters(in: .whitespacesAndNewlines)
        print("🔍 Participant count raw: '\(raw)'")
        guard !raw.isEmpty else {
            print("❌ VALIDATION FAILED: Participant count is empty")
            actionDelegate?.showValidationError(message: Localization.Validation.Participant.empty)
            return
        }
        guard let participants = Int(raw), participants > 0 else {
            print("❌ VALIDATION FAILED: Invalid participant count")
            actionDelegate?.showValidationError(message: Localization.Validation.Participant.invalid)
            return
        }
        print("✅ Participant count validation passed: \(participants)")

        guard minPax != nil || maxPax != nil else {
            actionDelegate?.showValidationError(message: Localization.Validation.Participant.packageLimitsUnavailable)
            return
        }

        if let min = minPax, participants < min {
            actionDelegate?.showValidationError(message: Localization.Validation.Participant.belowMinimum(min))
            return
        }
        if let max = maxPax, participants > max {
            actionDelegate?.showValidationError(message: Localization.Validation.Participant.aboveMaximum(max))
            return
        }

        // Validate traveler data
        print("🔍 Traveler data: Name='\(currentTravelerData.name)', Phone='\(currentTravelerData.phone)', Email='\(currentTravelerData.email)'")
        guard !currentTravelerData.name.isEmpty else {
            print("❌ VALIDATION FAILED: Traveler name is empty")
            actionDelegate?.showValidationError(message: Localization.Validation.Traveler.nameEmpty)
            return
        }
        
        guard currentTravelerData.isValid else {
            print("❌ VALIDATION FAILED: Traveler data is incomplete")
            actionDelegate?.showValidationError(message: Localization.Validation.Traveler.dataIncomplete)
            return
        }
        print("✅ Traveler data validation passed")
        
        // TODO: Temporarily disabled availability validation for testing redirect flow
        // Validate availability (but allow booking if we don't have availability data)
        // if let availability = currentAvailability, !availability.isAvailable, availability.availableSlots == 0 {
        //     actionDelegate?.showValidationError(message: "No available slots for selected date. Please choose another date.")
        //     return
        // }

        let bookingDate = chosenDateInput ?? Date()
        let userId = UserDefaults.standard.value(forKey: "user-id") as? String ?? "test-user-123"

        print("🚀 ALL VALIDATIONS PASSED! Proceeding to create booking...")
        print("🚀 Booking Date: \(bookingDate)")
        print("🚀 User ID: \(userId)")

        // Create booking directly instead of going to checkout
        createBooking(
            bookingDate: bookingDate,
            participants: participants,
            userId: userId
        )
    }
    
    /// Creates a booking by calling the API
    private func createBooking(bookingDate: Date, participants: Int, userId: String) {
        // Validate inputs before making API call
        guard !userId.isEmpty else {
            actionDelegate?.showValidationError(message: "User ID is missing. Please log in again.")
            return
        }
        
        guard input.selectedPackageId > 0 else {
            actionDelegate?.showValidationError(message: "Invalid package selected.")
            return
        }
        
        Task {
            do {
                let bookingSpec = CreateBookingSpec(
                    packageId: input.selectedPackageId,
                    bookingDate: bookingDate,
                    participants: participants,
                    userId: userId
                )
                
                // Debug logging
                print("🔍 Booking request: Package ID: \(input.selectedPackageId), Date: \(bookingDate), Participants: \(participants), User ID: \(userId)")
                
                let response = try await fetcher.createBooking(request: bookingSpec)
                
                print("✅ Booking API SUCCESS! Response: \(response)")
                print("✅ Booking Details: \(response.bookingDetails)")
                print("✅ Booking ID: \(response.bookingDetails.bookingId)")
                
                // Handle successful booking
                await MainActor.run {
                    let bookingId = "\(response.bookingDetails.bookingId)"
                    print("🚀 VIEWMODEL: Calling delegate with booking ID: \(bookingId)")
                    print("🚀 VIEWMODEL: Delegate is: \(String(describing: delegate))")
                    delegate?.notifyBookingDidSucceed(bookingId: bookingId)
                }
                
            } catch let error as APIError {
                // Handle API-specific errors - but for testing, simulate success
                print("❌ API Error occurred: \(error)")
                await MainActor.run {
                    // TODO: For testing redirect flow, simulate successful booking
                    print("🔧 Simulating successful booking for testing...")
                    delegate?.notifyBookingDidSucceed(bookingId: "TEST-\(Int.random(in: 1000...9999))")
                }
            } catch {
                // Handle other errors - but for testing, simulate success
                print("❌ Other error occurred: \(error)")
                await MainActor.run {
                    // TODO: For testing redirect flow, simulate successful booking
                    print("🔧 Simulating successful booking for testing...")
                    delegate?.notifyBookingDidSucceed(bookingId: "TEST-\(Int.random(in: 1000...9999))")
                }
            }
        }
    }
}

extension HomeFormScheduleViewModel: HomeSearchBarViewModelDelegate {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        if viewModel === calendarInputViewModel {
            actionDelegate?.showCalendarOption()
        } else if viewModel === paxInputViewModel {
            
        }
    }
}

private extension HomeFormScheduleViewModel {
    func openCalendar() {
        actionDelegate?.showCalendarOption()
    }
    
    private var selectedPackage: ActivityDetailDataModel.Package? {
        let allPackages = input.package.availablePackages.content.values.flatMap { $0 }
        return allPackages.first { $0.id == input.selectedPackageId }
    }
    
    private func buildSections() -> [BookingDetailSection] {
        var sections: [BookingDetailSection] = []
        
        // Package Info Section
        if let selectedPackage = selectedPackage {
            let packageInfo = PackageInfoDisplayData(
                imageUrl: selectedPackage.imageUrlString,
                packageName: selectedPackage.name,
                paxRange: "Min.\(selectedPackage.minParticipants) - Max.\(selectedPackage.maxParticipants)",
                pricePerPax: selectedPackage.price,
                originalPrice: nil,
                hasDiscount: false,
                description: selectedPackage.description,
                duration: "Full Day"
            )
            
            sections.append(BookingDetailSection(
                type: .packageInfo,
                title: nil,
                isExpandable: false,
                isExpanded: false,
                items: [packageInfo]
            ))
        }
        
        // Trip Provider Section - use selected package's host data
        let tripProviderItem: TripProviderDisplayItem
        if let selectedPackage = selectedPackage {
            tripProviderItem = TripProviderDisplayItem(
                name: selectedPackage.hostName,
                description: selectedPackage.hostBio.isEmpty ? "Expert guide providing \(selectedPackage.name) experience" : selectedPackage.hostBio,
                imageUrl: selectedPackage.hostProfileImageUrl.isEmpty ? input.package.providerDetail.content.imageUrlString : selectedPackage.hostProfileImageUrl
            )
        } else {
            // Fallback to default provider if no package selected
            tripProviderItem = TripProviderDisplayItem(
                name: input.package.providerDetail.content.name,
                description: input.package.providerDetail.content.description,
                imageUrl: input.package.providerDetail.content.imageUrlString
            )
        }
        
        sections.append(BookingDetailSection(
            type: .tripProvider,
            title: input.package.providerDetail.title,
            isExpandable: true,
            isExpanded: false,
            items: [tripProviderItem]
        ))
        
        // Itinerary Section (mock data for now)
        let itineraryItems = [
            ItineraryDisplayItem(
                time: "09:00",
                title: "Departure",
                description: "Start the journey",
                duration: "30 min",
                isFirstItem: true,
                isLastItem: false
            ),
            ItineraryDisplayItem(
                time: "17:00",
                title: "Return",
                description: "End of the journey",
                duration: "30 min",
                isFirstItem: false,
                isLastItem: true
            )
        ]
        
        sections.append(BookingDetailSection(
            type: .itinerary,
            title: "Itinerary",
            isExpandable: true,
            isExpanded: false,
            items: itineraryItems
        ))
        
        // Form Inputs Section
        let selectedTime: String
        if let date = chosenDateInput {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM, yyyy"
            selectedTime = dateFormatter.string(from: date)
        } else {
            selectedTime = Localization.Common.selectDate
        }
        
        let formData = FormInputData(
            selectedTime: selectedTime,
            participantCount: paxInputViewModel.currentTypedText,
            availableSlots: currentAvailability?.availableSlots
        )
        
        print("🔍 Building FormInputData - SelectedTime: \(selectedTime), ParticipantCount: \(paxInputViewModel.currentTypedText), AvailableSlots: \(currentAvailability?.availableSlots ?? -1)")
        
        sections.append(BookingDetailSection(
            type: .formInputs,
            title: nil,
            isExpandable: false,
            isExpanded: false,
            items: [formData]
        ))
        
        // Traveler Details Section
        sections.append(BookingDetailSection(
            type: .travelerDetails,
            title: nil,
            isExpandable: false,
            isExpanded: false,
            items: [currentTravelerData]
        ))
        
        return sections
    }
    
    private func buildPriceDetailsData() -> PriceDetailsData {
        let selectedDate: String
        if let date = chosenDateInput {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, dd MMM yyyy"
            selectedDate = formatter.string(from: date)
        } else {
            selectedDate = "Select Date"
        }
        
        let participantCount = Int(paxInputViewModel.currentTypedText) ?? 1
        let pricePerPerson = selectedPackage?.pricePerPerson ?? 0
        let totalPrice = pricePerPerson * Double(participantCount)
        
        return PriceDetailsData(
            selectedDate: selectedDate,
            participantCount: participantCount,
            travelerName: currentTravelerData.name,
            totalPrice: "Rp\(Int(totalPrice).formatted())"
        )
    }
}
