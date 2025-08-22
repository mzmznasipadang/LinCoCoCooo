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
    /// Called when the booking creation is successful and should navigate to checkout
    /// - Parameter response: The booking response containing booking details
    func notifyFormScheduleDidNavigateToCheckout(with response: CreateBookingResponse)
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
    
    /// Updates the table view with new sections data
    /// - Parameter sections: Array of booking detail sections to display
    func updateTableSections(_ sections: [BookingDetailSection])
    
    /// Updates the price details view with booking summary
    /// - Parameter data: Price details data containing booking information
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
}
