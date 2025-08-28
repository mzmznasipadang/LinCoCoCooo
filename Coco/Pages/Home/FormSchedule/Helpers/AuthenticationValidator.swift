//
//  AuthenticationValidator.swift
//  Coco
//
//  Created by Claude on 28/08/25.
//

import Foundation
import UIKit

// MARK: - Authentication Validator
internal class AuthenticationValidator {
    
    // MARK: - Authentication State
    
    /// Checks if user is currently logged in
    /// Returns true if user has a valid authentication token/ID
    /// Integrates with existing SignIn system in Profile module
    static func isUserLoggedIn() -> Bool {
        // Check for actual user ID from existing SignIn system
        // The SignIn system saves userId to UserDefaults on successful login
        if let userId = UserDefaults.standard.string(forKey: "user-id"),
           !userId.isEmpty {
            return true
        }
        
        return false
    }
    
    /// Gets the current user ID if logged in
    static func getCurrentUserId() -> String? {
        guard isUserLoggedIn() else { return nil }
        return UserDefaults.standard.string(forKey: "user-id")
    }
    
    // MARK: - Validation Methods
    
    /// Validates authentication before allowing form interaction
    /// Returns validation result with appropriate action
    static func validateAuthenticationForBooking() -> AuthValidationResult {
        if isUserLoggedIn() {
            return .success
        } else {
            return .requiresLogin(message: "Please log in to continue with your booking")
        }
    }
    
    /// Validates authentication and shows appropriate UI response
    static func validateAndHandleAuthentication(
        from viewController: UIViewController,
        onSuccess: @escaping () -> Void,
        onLoginRequired: @escaping () -> Void = {}
    ) {
        let result = validateAuthenticationForBooking()
        
        switch result {
        case .success:
            onSuccess()
            
        case .requiresLogin(let message):
            showLoginRequiredAlert(
                from: viewController,
                message: message,
                onLogin: onLoginRequired
            )
        }
    }
    
    // MARK: - UI Helpers
    
    /// Shows a login popup overlay when user needs to authenticate
    static func showLoginPopup(
        from viewController: UIViewController,
        onLogin: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "Login Required",
            message: "Please log in to continue with your booking",
            preferredStyle: .alert
        )
        
        // Login button
        let loginAction = UIAlertAction(title: "Login", style: .default) { _ in
            // Navigate to login immediately - UIAlertController will auto-dismiss
            onLogin()
        }
        
        // Cancel button  
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(loginAction)
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true)
    }
    
    private static func showLoginRequiredAlert(
        from viewController: UIViewController,
        message: String,
        onLogin: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "Login Required",
            message: message,
            preferredStyle: .alert
        )
        
        // Login button
        let loginAction = UIAlertAction(title: "Login", style: .default) { _ in
            onLogin()
        }
        
        // Cancel button  
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(loginAction)
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true)
    }
}

// MARK: - Authentication Validation Result
enum AuthValidationResult {
    case success
    case requiresLogin(message: String)
}

// MARK: - Authentication State Observer
protocol AuthenticationStateObserver: AnyObject {
    func userDidLogin()
    func userDidLogout()
}

// MARK: - Authentication State Manager
internal class AuthenticationStateManager {
    static let shared = AuthenticationStateManager()
    private var observers: [WeakWrapper] = []
    
    private init() {}
    
    func addObserver(_ observer: AuthenticationStateObserver) {
        observers.append(WeakWrapper(observer))
        cleanupObservers()
    }
    
    func removeObserver(_ observer: AuthenticationStateObserver) {
        observers.removeAll { $0.observer === observer }
    }
    
    func notifyLogin() {
        cleanupObservers()
        observers.compactMap { $0.observer }.forEach { $0.userDidLogin() }
    }
    
    func notifyLogout() {
        cleanupObservers()
        observers.compactMap { $0.observer }.forEach { $0.userDidLogout() }
    }
    
    private func cleanupObservers() {
        observers = observers.filter { $0.observer != nil }
    }
}

// MARK: - Weak Reference Helper
private class WeakWrapper {
    weak var observer: AuthenticationStateObserver?
    
    init(_ observer: AuthenticationStateObserver) {
        self.observer = observer
    }
}
