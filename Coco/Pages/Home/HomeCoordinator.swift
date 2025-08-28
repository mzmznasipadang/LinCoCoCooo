//
//  HomeCoordinator.swift
//  Coco
//
//  Created by Jackie Leonardy on 01/07/25.
//

import Foundation
import UIKit
import SwiftUI

final class HomeCoordinator: BaseCoordinator {
    struct Input {
        let navigationController: UINavigationController
        let flow: Flow
        
        enum Flow {
            case activityDetail(data: ActivityDetailDataModel)
        }
    }
    
    init(input: Input) {
        self.input = input
        super.init(navigationController: input.navigationController)
    }
    
    override func start() {
        super.start()
        
        switch input.flow {
        case .activityDetail(let data):
            let detailViewModel: ActivityDetailViewModel = ActivityDetailViewModel(
                data: data
            )
            // Set the navigation delegate BEFORE creating the view controller
            detailViewModel.navigationDelegate = self
            let detailViewController: ActivityDetailViewController = ActivityDetailViewController(viewModel: detailViewModel)
            start(viewController: detailViewController)
        }
    }
    
    private let input: Input
    
    /// Helper function to find BaseTabBarViewController in the view hierarchy
    private func findTabBarController(in viewController: UIViewController) -> BaseTabBarViewController? {
        if let tabBar = viewController as? BaseTabBarViewController {
            return tabBar
        }
        
        for child in viewController.children {
            if let found = findTabBarController(in: child) {
                return found
            }
        }
        
        if let presented = viewController.presentedViewController {
            if let found = findTabBarController(in: presented) {
                return found
            }
        }
        
        return nil
    }
}

extension HomeCoordinator: HomeViewModelNavigationDelegate {
    func notifyHomeDidSelectActivity() {
        
    }
}

extension HomeCoordinator: HomeFormScheduleViewModelDelegate {
    func notifyFormScheduleDidNavigateToCheckout(
        package: ActivityDetailDataModel,
        selectedPackageId: Int,
        bookingDate: Date,
        participants: Int,
        userId: String
    ) {
        let viewModel = CheckoutViewModel(
            package: package,
            selectedPackageId: selectedPackageId,
            bookingDate: bookingDate,
            participants: participants,
            userId: userId
        )
        viewModel.delegate = self
        let viewController = CheckoutViewController(viewModel: viewModel)

        DispatchQueue.main.async { [weak self] in
            self?.start(viewController: viewController)
        }
    }
    
    func notifyBookingDidSucceed(bookingId: String) {
        print("🎉 COORDINATOR: Booking succeeded with ID: \(bookingId)")
        
        // Navigate to MyTrip first, then show popup
        navigateToMyTripTab { [weak self] in
            self?.showCheckoutCompletedPopup()
        }
    }
    
    func navigateToLogin() {
        handleNavigateToLogin()
    }
    
    /// Shows the checkout completed popup
    private func showCheckoutCompletedPopup() {
        // Find the MyTrip tab's top view controller to present the popup
        guard let tabBarController = findTabBarController(),
              let myTripNavController = tabBarController.viewControllers?[1] as? UINavigationController,
              let topViewController = myTripNavController.topViewController else {
            print("❌ COORDINATOR: Could not find MyTrip view controller to show popup")
            return
        }
        
        let checkoutCompletedView = CheckoutCompletedPopUpView {
            // Just dismiss the popup when Continue is tapped
            topViewController.dismiss(animated: true)
        }
        
        let hostingController = UIHostingController(rootView: checkoutCompletedView)
        hostingController.modalPresentationStyle = .overFullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        
        // Make the background transparent since SwiftUI view handles its own background
        hostingController.view.backgroundColor = UIColor.clear
        
        topViewController.present(hostingController, animated: true)
        print("✅ COORDINATOR: Checkout completed popup presented on MyTrip tab!")
    }
    
    /// Navigates to MyTrip tab with completion callback
    private func navigateToMyTripTab(completion: @escaping () -> Void) {
        guard let tabBarController = findTabBarController() else {
            print("❌ COORDINATOR: Could not find tab bar controller")
            return
        }
        
        print("✅ COORDINATOR: Found tab bar controller, switching to MyTrip tab...")
        
        // Switch to MyTrip tab (index 1) and pop to root
        tabBarController.selectedIndex = 1
        navigationController?.popToRootViewController(animated: true)
        
        print("✅ COORDINATOR: Switched to tab index 1 and popped to root")
        
        // Show popup after a brief delay to ensure navigation is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }
    
    /// Helper to find tab bar controller
    private func findTabBarController() -> BaseTabBarViewController? {
        // Try multiple paths to find the tab bar controller
        if let currentTabBar = navigationController?.tabBarController as? BaseTabBarViewController {
            print("✅ COORDINATOR: Found tab bar through navigationController")
            return currentTabBar
        }
        else if let parentTabBar = parentCoordinator?.navigationController?.tabBarController as? BaseTabBarViewController {
            print("✅ COORDINATOR: Found tab bar through parentCoordinator")
            return parentTabBar
        }
        else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = windowScene.windows.first?.rootViewController,
                let foundTabBar = findTabBarController(in: rootViewController) {
            print("✅ COORDINATOR: Found tab bar through view hierarchy search")
            return foundTabBar
        }
        
        print("❌ COORDINATOR: Could not find tab bar controller through any method")
        return nil
    }
    
    /// Handles navigation to login screen - shared implementation for both protocols
    private func handleNavigateToLogin() {
        print("🔍 COORDINATOR: Navigation to login screen requested")
        
        // Navigate to Profile tab which contains the SignIn functionality
        // The Profile tab automatically shows SignIn when user is not logged in
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // First dismiss any presented view controllers
            if let presentedVC = self.navigationController?.topViewController?.presentedViewController {
                presentedVC.dismiss(animated: true) {
                    // Navigate to Profile tab after dismissal
                    self.performTabNavigation()
                }
            } else {
                self.performTabNavigation()
            }
        }
    }
    
    private func performTabNavigation() {
        if let tabBarController = self.findTabBarController() {
            tabBarController.selectedIndex = 2 // Profile tab (index 2)
            print("✅ COORDINATOR: Navigated to Profile tab for login")
            
            // Ensure the Profile view loads properly by accessing the Profile tab's view controller
            if let profileNavController = tabBarController.viewControllers?[2] as? UINavigationController,
               let profileViewController = profileNavController.viewControllers.first as? ProfileViewController {
                // Trigger viewWillAppear to ensure proper state
                profileViewController.viewWillAppear(true)
                print("✅ COORDINATOR: Profile view refreshed for login")
            }
        } else {
            print("❌ COORDINATOR: Could not find TabBarController to navigate to Profile tab")
            
            // Fallback: Show alert if tab navigation fails
            if let topViewController = self.navigationController?.topViewController {
                let alert = UIAlertController(
                    title: "Login Required", 
                    message: "Please navigate to the Profile tab to sign in",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                topViewController.present(alert, animated: true)
            }
        }
    }
}

extension HomeCoordinator: CheckoutViewModelDelegate {
    func notifyUserDidCheckout() {
        guard let tabBarController: BaseTabBarViewController = parentCoordinator?.navigationController?.tabBarController as? BaseTabBarViewController
        else {
            return
        }
        
        // Switch to MyTrip tab
        tabBarController.selectedIndex = 1
        
        // Get the MyTrip navigation controller and trigger refresh
        if let myTripNavController = tabBarController.viewControllers?[1] as? UINavigationController,
           let myTripViewController = myTripNavController.viewControllers.first as? MyTripViewController {
            // Trigger viewWillAppear to refresh the data
            myTripViewController.viewWillAppear(true)
        }
        
        navigationController?.popToRootViewController(animated: true)
    }
}

extension HomeCoordinator: ActivityDetailNavigationDelegate {
    func notifyActivityDetailPackageDidSelect(package: ActivityDetailDataModel, selectedPackageId: Int) {
        let viewModel: HomeFormScheduleViewModel = HomeFormScheduleViewModel(
            input: HomeFormScheduleViewModelInput(
                package: package,
                selectedPackageId: selectedPackageId
            )
        )
        viewModel.delegate = self
        let viewController: HomeFormScheduleViewController = HomeFormScheduleViewController(viewModel: viewModel)
        start(viewController: viewController)
    }
}

// MARK: - UIViewController Extension
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController() ?? self
        }
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController() ?? self
        }
        return self
    }
}
