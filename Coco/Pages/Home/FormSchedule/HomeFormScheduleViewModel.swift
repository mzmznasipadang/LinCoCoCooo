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
    var participantCount: String = "1"
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
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with package data and network fetcher
    /// - Parameters:
    ///   - input: Package and selection data
    ///   - fetcher: Network service for booking creation (injectable for testing)
    init(input: HomeFormScheduleViewModelInput, fetcher: CreateBookingFetcherProtocol = CreateBookingFetcher()) {
        self.input = input
        self.fetcher = fetcher
    }
    
    // MARK: - Properties
    
    /// Input data containing package details and selected package ID
    let input: HomeFormScheduleViewModelInput
    
    /// ViewModel for the calendar/date input field
    /// Configured as non-typeable with calendar icon trigger
    private lazy var calendarInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "Input Date Visit...",
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
        placeholderText: "Input total Pax...",
        currentTypedText: "1",
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
    
    // MARK: - Private Methods
    
    /// Triggers the calendar selection popup through the action delegate
    private func openCalendar() {
        actionDelegate?.showCalendarOption()
    }
}

// MARK: - HomeFormScheduleViewModelProtocol

extension HomeFormScheduleViewModel: HomeFormScheduleViewModelProtocol {
    /// Sets up the initial view state when the view loads
    /// Configures input views and builds the initial table sections
    func onViewDidLoad() {
        // Setup bottom input views
        actionDelegate?.setupView(
            calendarViewModel: calendarInputViewModel,
            paxInputViewModel: paxInputViewModel
        )
        
        // Build and set table sections
        let sections = buildSections()
        actionDelegate?.updateTableSections(sections)
        
        // Update price details
        let priceData = buildPriceDetailsData()
        actionDelegate?.updatePriceDetails(priceData)
    }
    
    /// Handles date selection from the calendar
    /// Updates the internal date state and refreshes the UI immediately
    /// - Parameter date: The selected date
    func onCalendarDidChoose(date: Date) {
        chosenDateInput = date
        // Rebuild sections to reflect the updated date
        let sections = buildSections()
        actionDelegate?.updateTableSections(sections)
        
        // Update price details
        let priceData = buildPriceDetailsData()
        actionDelegate?.updatePriceDetails(priceData)
    }
    
    /// Handles checkout button tap
    /// Validates participant count against package constraints and creates booking
    /// Shows validation errors if constraints are not met
    func onCheckout() {
        // Filtering numeric only in Pax Field
        let currentPaxText = paxInputViewModel.currentTypedText
        let sanitizedPaxText = currentPaxText.filter { "0123456789".contains($0) }
        let finalPaxText = sanitizedPaxText.isEmpty ? "1" : sanitizedPaxText
        paxInputViewModel.currentTypedText = finalPaxText
        let participants = Int(finalPaxText) ?? 1
        
        // Validate against min/max participants
        guard let selectedPackage = input.package.availablePackages.content.first(where: { $0.id == input.selectedPackageId }) else {
            print("Selected package not found")
            return
        }
        
        guard participants >= selectedPackage.minParticipants && participants <= selectedPackage.maxParticipants else {
            print("Participant count (\(participants)) is outside valid range: \(selectedPackage.minParticipants)-\(selectedPackage.maxParticipants)")
            // TODO: Show validation error to user
            return
        }
        
        Task {
            do {
                let request = CreateBookingSpec(
                    packageId: input.selectedPackageId,
                    bookingDate: chosenDateInput ?? Date(),
                    participants: participants,
                    userId: UserDefaults.standard.value(forKey: "user-id") as? String ?? ""
                )
                
                let response = try await fetcher.createBooking(request: request)
                delegate?.notifyFormScheduleDidNavigateToCheckout(with: response)
            } catch {
                print("Booking creation failed: \(error)")
            }
        }
    }
    
    /// Updates the participant count and refreshes the UI
    /// Called when user selects a participant count from the picker
    /// - Parameter count: The selected participant count
    func updateParticipantCount(_ count: Int) {
        paxInputViewModel.currentTypedText = "\(count)"
        // Rebuild sections to reflect the updated participant count
        let sections = buildSections()
        actionDelegate?.updateTableSections(sections)
        
        // Update price details
        let priceData = buildPriceDetailsData()
        actionDelegate?.updatePriceDetails(priceData)
    }
    
    /// Handles traveler data changes from the form
    /// Updates internal state and refreshes price details
    /// - Parameter data: Updated traveler information
    func onTravelerDataChanged(_ data: TravelerData) {
        currentTravelerData = data
        
        // Update price details to reflect traveler name
        let priceData = buildPriceDetailsData()
        actionDelegate?.updatePriceDetails(priceData)
    }
}

// MARK: - Private Methods

private extension HomeFormScheduleViewModel {
    /// Builds the complete array of table view sections for the booking form
    /// Combines package information, trip provider, itinerary, form inputs, and traveler details
    /// - Returns: Array of BookingDetailSection containing all the data to display
    func buildSections() -> [BookingDetailSection] {
        // Get sections from transformer with package info, trip provider, and itinerary
        var sections = BookingDetailDataTransformer.transform(
            activityDetail: input.package,
            selectedPackageId: input.selectedPackageId
        )
        
        // Add form input section
        let formData = FormInputData(
            selectedTime: chosenDateInput != nil ? calendarInputViewModel.currentTypedText : "Select Date",
            participantCount: paxInputViewModel.currentTypedText
        )
        let formSection = BookingDetailSection(
            type: .formInputs,
            title: nil,
            isExpandable: false,
            isExpanded: true,
            items: [formData]
        )
        sections.append(formSection)
        
        // Add traveler details section
        let travelerData = TravelerData(name: "", phone: "", email: "")
        let travelerSection = BookingDetailSection(
            type: .travelerDetails,
            title: "Traveler details",
            isExpandable: false,
            isExpanded: true,
            items: [travelerData]
        )
        sections.append(travelerSection)
        
        return sections
    }
    
    /// Builds price details data for the bottom sticky section
    /// - Returns: PriceDetailsData containing current booking information
    func buildPriceDetailsData() -> PriceDetailsData {
        // Get selected package for price calculation
        guard let selectedPackage = input.package.availablePackages.content.first(where: { $0.id == input.selectedPackageId }) else {
            return PriceDetailsData(
                selectedDate: "Select Date",
                participantCount: 1,
                travelerName: "",
                totalPrice: "Rp0"
            )
        }
        
        // Format selected date
        let dateString: String
        if let chosenDateInput = chosenDateInput {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, dd MMM yyyy" // "Wed, 21 May 2024"
            dateString = formatter.string(from: chosenDateInput)
        } else {
            dateString = "Select Date"
        }
        
        // Get participant count
        let participantCount = Int(paxInputViewModel.currentTypedText) ?? 1
        
        // Calculate total price
        let pricePerPerson = selectedPackage.pricePerPerson
        let totalPrice = pricePerPerson * Double(participantCount)
        
        // Format price
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        let formattedPrice = "Rp\(numberFormatter.string(from: NSNumber(value: totalPrice)) ?? "0")"
        
        // Get traveler name from current form data
        let travelerName = currentTravelerData.name
        
        return PriceDetailsData(
            selectedDate: dateString,
            participantCount: participantCount,
            travelerName: travelerName,
            totalPrice: formattedPrice
        )
    }
}

// MARK: - HomeSearchBarViewModelDelegate

extension HomeFormScheduleViewModel: HomeSearchBarViewModelDelegate {
    /// Handles tap events from the search bar input fields
    /// Currently only handles calendar input taps to show date selection
    /// - Parameters:
    ///   - isTypeAble: Whether the field allows typing
    ///   - viewModel: The specific search bar view model that was tapped
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        if viewModel === calendarInputViewModel {
            actionDelegate?.showCalendarOption()
        }
    }
}

//import Foundation
//
//struct HomeFormScheduleViewModelInput {
//    let package: ActivityDetailDataModel
//    let selectedPackageId: Int
//}
//
//final class HomeFormScheduleViewModel {
//    weak var delegate: (any HomeFormScheduleViewModelDelegate)?
//    weak var actionDelegate: (any HomeFormScheduleViewModelAction)?
//    
//    init(input: HomeFormScheduleViewModelInput, fetcher: CreateBookingFetcherProtocol = CreateBookingFetcher()) {
//        self.input = input
//        self.fetcher = fetcher
//    }
//    
//    private let input: HomeFormScheduleViewModelInput
//    private lazy var calendarInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
//        leadingIcon: nil,
//        placeholderText: "Input Date Visit...",
//        currentTypedText: "",
//        trailingIcon: (
//            image: CocoIcon.icFilterIcon.image,
//            didTap: openCalendar
//        ),
//        isTypeAble: false,
//        delegate: self
//    )
//    private lazy var paxInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
//        leadingIcon: nil,
//        placeholderText: "Input total Pax...",
//        currentTypedText: "1",
//        trailingIcon: nil,
//        isTypeAble: true,
//        delegate: self,
//        keyboardType: .numberPad
//    )
//    private var chosenDateInput: Date? {
//        didSet {
//            guard let chosenDateInput else { return }
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd MMMM, yyyy"
//            calendarInputViewModel.currentTypedText = dateFormatter.string(from: chosenDateInput)
//        }
//    }
//    private let fetcher: CreateBookingFetcherProtocol
//}
//
//extension HomeFormScheduleViewModel: HomeFormScheduleViewModelProtocol {
//    func onViewDidLoad() {
//        // Setup bottom input views
//        actionDelegate?.setupView(
//            calendarViewModel: calendarInputViewModel,
//            paxInputViewModel: paxInputViewModel
//        )
//        
//        // Build and set table sections
//        let sections = buildSections()
//        actionDelegate?.updateTableSections(sections)
//    }
//    
//    func onCalendarDidChoose(date: Date) {
//        chosenDateInput = date
//    }
//    
//    func onCheckout() {
//        // Filtering numeric only in Pax Field
//        let currentPaxText = paxInputViewModel.currentTypedText
//        let sanitizedPaxText = currentPaxText.filter { "0123456789".contains($0) }
//        let finalPaxText = sanitizedPaxText.isEmpty ? "1" : sanitizedPaxText
//        paxInputViewModel.currentTypedText = finalPaxText
//        let participants = Int(finalPaxText) ?? 1
//        
//        Task {
//            do {
//                let request = CreateBookingSpec(
//                    packageId: input.selectedPackageId,
//                    bookingDate: chosenDateInput ?? Date(),
//                    participants: participants,
//                    userId: UserDefaults.standard.value(forKey: "user-id") as? String ?? ""
//                )
//                
//                let response = try await fetcher.createBooking(request: request)
//                delegate?.notifyFormScheduleDidNavigateToCheckout(with: response)
//            } catch {
//                print("Booking creation failed: \(error)")
//            }
//        }
//    }
//}
//
//// MARK: - Private Methods
//private extension HomeFormScheduleViewModel {
//    func buildSections() -> [BookingDetailSection] {
//        // Get existing sections from transformer
//        var sections = BookingDetailDataTransformer.transform(
//            activityDetail: input.package,
//            selectedPackageId: input.selectedPackageId
//        )
//        
//        // Add form input section
//        let formSection = BookingDetailSection(
//            type: .formInputs,
//            title: nil,
//            items: [FormInputData()], // You'll need to create this struct
//            isExpandable: false,
//            isExpanded: true
//        )
//        sections.append(formSection)
//        
//        // Add traveler details section
//        let travelerSection = BookingDetailSection(
//            type: .travelerDetails,
//            title: "Traveler details",
//            items: [TravelerData()], // You'll need to create this struct
//            isExpandable: false,
//            isExpanded: true
//        )
//        sections.append(travelerSection)
//        
//        return sections
//    }
//}
//
//// MARK: - HomeSearchBarViewModelDelegate
//extension HomeFormScheduleViewModel: HomeSearchBarViewModelDelegate {
//    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
//        if viewModel === calendarInputViewModel {
//            actionDelegate?.showCalendarOption()
//        }
//    }
//}


//import Foundation
//
//struct HomeFormScheduleViewModelInput {
//    let package: ActivityDetailDataModel
//    let selectedPackageId: Int
//}
//
//final class HomeFormScheduleViewModel {
//    weak var delegate: (any HomeFormScheduleViewModelDelegate)?
//    weak var actionDelegate: (any HomeFormScheduleViewModelAction)?
//
//    init(input: HomeFormScheduleViewModelInput, fetcher: CreateBookingFetcherProtocol = CreateBookingFetcher()) {
//        self.input = input
//        self.fetcher = fetcher
//    }
//
//    private let input: HomeFormScheduleViewModelInput
//    private lazy var calendarInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
//        leadingIcon: nil,
//        placeholderText: "Input Date Visit...",
//        currentTypedText: "", // For making sure that the minimum pax is 1 person
//        trailingIcon: (
//            image: CocoIcon.icFilterIcon.image,
//            didTap: openCalendar
//        ),
//        isTypeAble: false,
//        delegate: self
//    )
//    private lazy var paxInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
//        leadingIcon: nil,
//        placeholderText: "Input total Pax...",
//        currentTypedText: "1", // For making sure that the minimum pax is 1 person
//        trailingIcon: nil,
//        isTypeAble: true,
//        delegate: self,
//        keyboardType: .numberPad
//    )
//    private var chosenDateInput: Date? {
//        didSet {
//            guard let chosenDateInput else { return }
//            let dateFormatter: DateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd MMMM, yyyy"
//            calendarInputViewModel.currentTypedText = dateFormatter.string(from: chosenDateInput)
//        }
//    }
//    private let fetcher: CreateBookingFetcherProtocol
//}
//
//extension HomeFormScheduleViewModel: HomeFormScheduleViewModelProtocol {
//    func onViewDidLoad() {
//        actionDelegate?.setupView(
//            calendarViewModel: calendarInputViewModel,
//            paxInputViewModel: paxInputViewModel
//        )
//
//        let data: HomeFormScheduleViewData = HomeFormScheduleViewData(
//            imageString: input.package.imageUrlsString.first ?? "",
//            activityName: input.package.title,
//            packageName: input.package.availablePackages.content.first { $0.id == input.selectedPackageId }?.name ?? "",
//            location: input.package.location
//        )
//
//        actionDelegate?.configureView(data: data)
//    }
//
//    func onCalendarDidChoose(date: Date) {
//        chosenDateInput = date
//    }
//
//    func onCheckout() {
//        // Filtering numeric only in Pax Field
//        let currentPaxText = paxInputViewModel.currentTypedText
//            let sanitizedPaxText = currentPaxText.filter { "0123456789".contains($0) }
//        let finalPaxText = sanitizedPaxText.isEmpty ? "1" : sanitizedPaxText
//            paxInputViewModel.currentTypedText = finalPaxText
//        let participants = Int(finalPaxText) ?? 1
//
//        Task {
//            do {
//                let request: CreateBookingSpec = CreateBookingSpec(
//                    packageId: input.selectedPackageId,
//                    bookingDate: chosenDateInput ?? Date(),
//                    participants: Int(paxInputViewModel.currentTypedText) ?? 1,
//                    userId: UserDefaults.standard.value(forKey: "user-id") as? String ?? ""
//                )
//
//                let response: CreateBookingResponse = try await fetcher.createBooking(request: request)
//                delegate?.notifyFormScheduleDidNavigateToCheckout(with: response)
//            }
//            catch {
//                print("Booking creation failed: \(error)")
//            }
//        }
//    }
//}
//
//extension HomeFormScheduleViewModel: HomeSearchBarViewModelDelegate {
//    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
//        if viewModel === calendarInputViewModel {
//            actionDelegate?.showCalendarOption()
//        }
//        else if viewModel === paxInputViewModel {
//
//        }
//    }
//}
//
//private extension HomeFormScheduleViewModel {
//    func openCalendar() {
//
//    }
//}
