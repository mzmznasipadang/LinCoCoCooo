//
//  ActivityDetailViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import UIKit

final class ActivityDetailViewModel {
    weak var actionDelegate: ActivityDetailViewModelAction?
    weak var navigationDelegate: ActivityDetailNavigationDelegate?
    
    init(data: ActivityDetailDataModel) {
        self.data = data
    }
    
    private let data: ActivityDetailDataModel
}

extension ActivityDetailViewModel: ActivityDetailViewModelProtocol {
    func onViewDidLoad() {
        actionDelegate?.configureView(data: data)
    }
    
    func onPackagesDetailDidTap(with packageId: Int) {
        // Validate authentication before allowing booking navigation
        let authResult = AuthenticationValidator.validateAuthenticationForBooking()
        switch authResult {
        case .success:
            navigationDelegate?.notifyActivityDetailPackageDidSelect(package: data, selectedPackageId: packageId)
            
        case .requiresLogin:
            // Show login popup and navigate to login on confirmation
            if let viewController = actionDelegate as? UIViewController {
                AuthenticationValidator.showLoginPopup(from: viewController) { [weak self] in
                    self?.navigationDelegate?.navigateToLogin()
                }
            }
        }
    }
}
