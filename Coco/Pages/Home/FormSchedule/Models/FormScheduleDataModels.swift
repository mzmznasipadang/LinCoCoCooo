//
//  FormScheduleDataModels.swift
//  Coco
//
//  Created by Claude on 28/08/25.
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