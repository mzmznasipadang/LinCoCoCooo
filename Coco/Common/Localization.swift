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
    }
    
    // MARK: - Form Labels
    
    struct Form {
        struct TravelerDetails {
            static let name = string(for: "form.traveler_details.name")
            static let phone = string(for: "form.traveler_details.phone")
            static let email = string(for: "form.traveler_details.email")
            static let title = string(for: "form.traveler_details.title")
        }
    }
    
    // MARK: - Common Strings
    
    struct Common {
        static let selectDate = string(for: "common.select_date")
        static let typeHere = string(for: "common.type_here")
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