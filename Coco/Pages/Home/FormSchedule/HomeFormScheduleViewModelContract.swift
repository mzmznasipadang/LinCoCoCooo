//
//  HomeFormScheduleViewModelContract.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation

// MARK: - HomeFormScheduleViewModelDelegate

/// Delegate protocol for handling ViewModel events that require navigation or external actions
protocol HomeFormScheduleViewModelDelegate: AnyObject {
    func notifyFormScheduleDidNavigateToCheckout(
        package: ActivityDetailDataModel,
        selectedPackageId: Int,
        bookingDate: Date,
        participants: Int,
        userId: String
    )
    
    /// Called when booking is successfully created
    func notifyBookingDidSucceed(bookingId: String)
}

// MARK: - HomeFormScheduleViewModelAction

/// Protocol for ViewModel to communicate with ViewController for UI updates
protocol HomeFormScheduleViewModelAction: AnyObject {
    /// Sets up the input views (calendar and participant selectors) with their ViewModels
    /// - Parameters:
    ///   - calendarViewModel: ViewModel for the date selection input
    ///   - paxInputViewModel: ViewModel for the participant count input
    func setupView(
        calendarViewModel: HomeSearchBarViewModel,
        paxInputViewModel: HomeSearchBarViewModel
    )
    
    /// Configures the view with booking detail data (legacy method, not used in current implementation)
    /// - Parameter data: The view data for configuration
    func configureView(data: HomeFormScheduleViewData)
    
    /// Shows the calendar selection popup
    func showCalendarOption()
    func showValidationError(message: String)
    
    /// Updates the table view sections with new data
    /// - Parameter sections: Array of sections to display in the table view
    func updateTableSections(_ sections: [BookingDetailSection])
    
    /// Updates the price details view with new pricing information
    /// - Parameter data: Updated price details data
    func updatePriceDetails(_ data: PriceDetailsData)
}

// MARK: - HomeFormScheduleViewModelProtocol

/// Main ViewModel protocol for the booking form schedule screen
/// Handles date selection, participant validation, and booking creation
protocol HomeFormScheduleViewModelProtocol: AnyObject {
    /// Delegate for handling navigation and external actions
    var delegate: HomeFormScheduleViewModelDelegate? { get set }
    
    /// Action delegate for UI updates and interactions
    var actionDelegate: HomeFormScheduleViewModelAction? { get set }
    
    /// Input data containing package details and selected package ID
    var input: HomeFormScheduleViewModelInput { get }
    
    /// Called when the view has loaded, sets up initial UI state
    func onViewDidLoad()
    
    /// Called when user selects a date from the calendar
    /// Updates the date field and rebuilds table sections
    /// - Parameter date: The selected date
    func onCalendarDidChoose(date: Date)
    
    /// Called when user taps the checkout button
    /// Validates participant count against package constraints and creates booking
    func onCheckout()
    
    /// Called when user selects a participant count
    /// Updates the participant field and rebuilds table sections
    /// - Parameter count: The selected participant count
    func updateParticipantCount(_ count: Int)
    
    /// Called when traveler details form data changes
    /// Updates internal state and refreshes price details
    /// - Parameter data: Updated traveler information
    func onTravelerDataChanged(_ data: TravelerData)
}
