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
    
    private let activityFetcher: ActivityFetcherProtocol
    
    private var minPax: Int?
    private var maxPax: Int?
}

// MARK: - HomeFormScheduleViewModelProtocol

extension HomeFormScheduleViewModel: HomeFormScheduleViewModelProtocol {
    func refreshPaxPlaceholder() {
        let text: String
        switch (minPax, maxPax) {
        case let (min?, max?):
            text = "Input total Pax... \(min) - \(max) Person(s)"
        case let (min?, nil):
            text = "Input total Pax... min \(min) Person(s)"
        case let (nil, max?):
            text = "Input total Pax... up to \(max) Person(s)"
        default:
            text = "Input total Pax..."
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
        
        actionDelegate?.configureView(data: data)
        
        if let selected = input.package.availablePackages.content.first(where: { $0.id == input.selectedPackageId }) {
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
            actionDelegate?.showValidationError(message: "Masukkan jumlah orang terlebih dahulu.")
            return
        }
        guard let participants = Int(raw), participants > 0 else {
            actionDelegate?.showValidationError(message: "Jumlah orang harus berupa angka yang valid.")
            return
        }

        guard minPax != nil || maxPax != nil else {
            actionDelegate?.showValidationError(message: "Tidak dapat memuat batas peserta paket. Coba lagi memilih paket atau periksa koneksi.")
            return
        }

        if let min = minPax, participants < min {
            actionDelegate?.showValidationError(message: "Minimal peserta untuk paket ini adalah \(min) orang.")
            return
        }
        if let max = maxPax, participants > max {
            actionDelegate?.showValidationError(message: "Maksimal peserta untuk paket ini adalah \(max) orang.")
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
        
    }
}
