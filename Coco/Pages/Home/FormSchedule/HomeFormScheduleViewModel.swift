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
    
    init(input: HomeFormScheduleViewModelInput, fetcher: CreateBookingFetcherProtocol = CreateBookingFetcher(), activityFetcher: ActivityFetcherProtocol = ActivityFetcher()) {
        self.input = input
        self.fetcher = fetcher
        self.activityFetcher = activityFetcher
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
    
    private let activityFetcher: ActivityFetcherProtocol
    
    private var minPax: Int?
    private var maxPax: Int?
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
        
        // Build and set table sections
        let sections = buildSections()
        actionDelegate?.updateTableSections(sections)
        
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
        let raw = paxInputViewModel.currentTypedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else {
            actionDelegate?.showValidationError(message: Localization.Validation.Participant.empty)
            return
        }
        guard let participants = Int(raw), participants > 0 else {
            actionDelegate?.showValidationError(message: Localization.Validation.Participant.invalid)
            return
        }

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
        guard !currentTravelerData.name.isEmpty else {
            actionDelegate?.showValidationError(message: Localization.Validation.Traveler.nameEmpty)
            return
        }
        
        guard currentTravelerData.isValid else {
            actionDelegate?.showValidationError(message: Localization.Validation.Traveler.dataIncomplete)
            return
        }

        let bookingDate = chosenDateInput ?? Date()
        let userId = UserDefaults.standard.value(forKey: "user-id") as? String ?? ""

        delegate?.notifyFormScheduleDidNavigateToCheckout(
            package: input.package,
            selectedPackageId: input.selectedPackageId,
            bookingDate: bookingDate,
            participants: participants,
            userId: userId
        )
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
        return input.package.availablePackages.content.first { $0.id == input.selectedPackageId }
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
        
        // Trip Provider Section
        let tripProviderItem = TripProviderDisplayItem(
            name: input.package.providerDetail.content.name,
            description: input.package.providerDetail.content.description,
            imageUrl: input.package.providerDetail.content.imageUrlString
        )
        
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
            participantCount: paxInputViewModel.currentTypedText
        )
        
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
