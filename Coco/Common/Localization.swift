//
//  Localization.swift
//  Coco
//
//  Created by Claude on 25/08/25.
//

import Foundation

// MARK: - Localization Helper

/// A centralized localization helper that provides easy access to localized strings
/// with support for formatted strings and fallback values
struct Localization {
    
    // MARK: - Core Localization Method
    
    /// Returns a localized string for the given key
    /// - Parameters:
    ///   - key: The localization key
    ///   - arguments: Optional arguments for string formatting
    /// - Returns: The localized string
    static func string(for key: String, _ arguments: CVarArg...) -> String {
        let localizedString = NSLocalizedString(key, comment: "")
        if arguments.isEmpty {
            return localizedString
        } else {
            return String(format: localizedString, arguments: arguments)
        }
    }
    
    // MARK: - Screen Titles
    
    struct Screen {
        static let home = string(for: "screen.home")
        static let myTrip = string(for: "screen.my_trip")
        static let profile = string(for: "screen.profile")
        static let signIn = string(for: "screen.sign_in")
        static let bookingDetail = string(for: "screen.booking_detail")
        static let checkout = string(for: "screen.checkout")
        static let detailMyTrip = string(for: "screen.detail_my_trip")
        static let settings = string(for: "screen.settings")
    }
    
    // MARK: - Validation Messages
    
    struct Validation {
        struct Participant {
            static let empty = string(for: "validation.participant.empty")
            static let invalid = string(for: "validation.participant.invalid")
            static let packageLimitsUnavailable = string(for: "validation.participant.package_limits_unavailable")
            
            static func belowMinimum(_ minimum: Int) -> String {
                return string(for: "validation.participant.below_minimum", minimum)
            }
            
            static func aboveMaximum(_ maximum: Int) -> String {
                return string(for: "validation.participant.above_maximum", maximum)
            }
        }
        
        struct Traveler {
            static let nameEmpty = string(for: "validation.traveler.name_empty")
            static let dataIncomplete = string(for: "validation.traveler.data_incomplete")
        }
        
        struct Phone {
            static let invalid = string(for: "validation.phone.invalid")
        }
        
        struct Email {
            static let invalid = string(for: "validation.email.invalid")
        }
        
        struct Name {
            static let required = string(for: "validation.name.required")
        }
        
        struct Alert {
            static let title = string(for: "validation.alert.title")
            static let ok = string(for: "validation.alert.ok")
        }
    }
    
    // MARK: - Form Labels
    
    struct Form {
        struct TravelerDetails {
            static let name = string(for: "form.traveler_details.name")
            static let phone = string(for: "form.traveler_details.phone")
            static let email = string(for: "form.traveler_details.email")
            static let title = string(for: "form.traveler_details.title")
        }
        
        static let selectDates = string(for: "form.select_dates")
        static let numberParticipants = string(for: "form.number_participants")
        static let selectTime = string(for: "form.select_time")
        static let selectParticipants = string(for: "form.select_participants")
        
        static func availableSlots(_ count: Int) -> String {
            return string(for: "form.available_slots", count)
        }
    }
    
    // MARK: - Authentication
    
    struct Auth {
        static let emailAddress = string(for: "auth.email_address")
        static let password = string(for: "auth.password")
        static let signIn = string(for: "auth.sign_in")
        static let enterEmail = string(for: "auth.enter_email")
        static let enterPassword = string(for: "auth.enter_password")
        static let logOut = string(for: "auth.log_out")
    }
    
    // MARK: - Trip & Booking
    
    struct Trip {
        static let payDuringTrip = string(for: "trip.pay_during_trip")
        static let person = string(for: "trip.person")
        
        struct Status {
            static let completed = string(for: "trip.status.completed")
            static let upcoming = string(for: "trip.status.upcoming")
        }
    }
    
    struct Booking {
        static let dateBooking = string(for: "booking.date_booking")
        static let status = string(for: "booking.status")
        static let person = string(for: "booking.person")
        static let meetingPoint = string(for: "booking.meeting_point")
        static let completed = string(for: "booking.completed")
        
        struct Success {
            static let title = string(for: "booking.success.title")
            static func message(_ bookingId: String) -> String {
                return string(for: "booking.success.message", bookingId)
            }
        }
    }
    
    // MARK: - Price & Payment
    
    struct Price {
        static let details = string(for: "price.details")
        static let dates = string(for: "price.dates")
        static let pax = string(for: "price.pax")
        static let name = string(for: "price.name")
        static let payDuringTrip = string(for: "price.pay_during_trip")
        static let bookNow = string(for: "price.book_now")
    }
    
    // MARK: - Package & Activity
    
    struct Package {
        static let showAll = string(for: "package.show_all")
        static let showLess = string(for: "package.show_less")
        static let freeCancellation = string(for: "package.free_cancellation")
        static let schedule = string(for: "package.schedule")
    }
    
    // MARK: - Search
    
    struct Search {
        static let title = string(for: "search.title")
        static let lastSearch = string(for: "search.last_search")
        static let popularLocation = string(for: "search.popular_location")
    }
    
    // MARK: - Common Strings
    
    struct Common {
        static let selectDate = string(for: "common.select_date")
        static let typeHere = string(for: "common.type_here")
        static let detail = string(for: "common.detail")
        static let cancel = string(for: "common.cancel")
        static let continueAction = string(for: "common.continue")
        static let search = string(for: "common.search")
        static let ok = string(for: "common.ok")
    }
    
    // MARK: - Formatting
    
    struct Format {
        static func minMaxParticipants(min: Int, max: Int) -> String {
            return string(for: "format.min_max_participants", min, max)
        }
        
        static func participantRangePerson(min: Int, max: Int) -> String {
            return string(for: "format.participant_range_person", min, max)
        }
        
        static func participantMinPerson(_ min: Int) -> String {
            return string(for: "format.participant_min_person", min)
        }
        
        static func participantMaxPerson(_ max: Int) -> String {
            return string(for: "format.participant_max_person", max)
        }
        
        static let participantDefault = string(for: "format.participant_default")
    }
    
    // MARK: - Placeholder Texts
    
    struct Placeholder {
        static let inputDateVisit = string(for: "placeholder.input_date_visit")
        static let inputTotalPax = string(for: "placeholder.input_total_pax")
        static let typeHere = string(for: "placeholder.type_here")
    }
}

// MARK: - String Extension for Convenience

extension String {
    /// Returns a localized version of the string
    /// Convenience method that uses the string itself as the key
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Returns a localized version of the string with arguments
    /// - Parameter arguments: Arguments for string formatting
    /// - Returns: Formatted localized string
    func localized(_ arguments: CVarArg...) -> String {
        let localizedString = NSLocalizedString(self, comment: "")
        if arguments.isEmpty {
            return localizedString
        } else {
            return String(format: localizedString, arguments: arguments)
        }
    }
}
