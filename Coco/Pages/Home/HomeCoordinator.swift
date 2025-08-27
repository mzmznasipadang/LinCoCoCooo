//
//  HomeCoordinator.swift
//  Coco
//
//  Created by Jackie Leonardy on 01/07/25.
//

import Foundation
import UIKit

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
        
        // Redirect to MyTrip tab after successful booking
        // Try multiple paths to find the tab bar controller
        var tabBarController: BaseTabBarViewController?
        
        // Option 1: Through current navigation controller
        if let currentTabBar = navigationController?.tabBarController as? BaseTabBarViewController {
            tabBarController = currentTabBar
            print("✅ COORDINATOR: Found tab bar through navigationController")
        }
        // Option 2: Through parent coordinator
        else if let parentTabBar = parentCoordinator?.navigationController?.tabBarController as? BaseTabBarViewController {
            tabBarController = parentTabBar
            print("✅ COORDINATOR: Found tab bar through parentCoordinator")
        }
        // Option 3: Search through the view hierarchy
        else if let rootViewController = UIApplication.shared.windows.first?.rootViewController,
                let foundTabBar = findTabBarController(in: rootViewController) {
            tabBarController = foundTabBar
            print("✅ COORDINATOR: Found tab bar through view hierarchy search")
        }
        
        guard let tabBarController = tabBarController else {
            print("❌ COORDINATOR: Could not find tab bar controller through any method")
            print("❌ COORDINATOR: navigationController?.tabBarController = \(String(describing: navigationController?.tabBarController))")
            print("❌ COORDINATOR: parentCoordinator?.navigationController?.tabBarController = \(String(describing: parentCoordinator?.navigationController?.tabBarController))")
            return
        }
        
        print("✅ COORDINATOR: Found tab bar controller, switching to MyTrip tab...")
        
        // Switch to MyTrip tab (index 1) and show booking confirmation
        tabBarController.selectedIndex = 1
        navigationController?.popToRootViewController(animated: true)
        
        print("✅ COORDINATOR: Switched to tab index 1 and popped to root")
        
        // Show success message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("✅ COORDINATOR: Showing success alert...")
            if let topController = tabBarController.selectedViewController?.topMostViewController() {
                let alert = UIAlertController(
                    title: Localization.Booking.Success.title, 
                    message: Localization.Booking.Success.message(bookingId), 
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: Localization.Common.ok, style: .default))
                topController.present(alert, animated: true)
                print("✅ COORDINATOR: Success alert presented!")
            } else {
                print("❌ COORDINATOR: Could not find top controller to show alert")
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
        tabBarController.selectedIndex = 1
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
