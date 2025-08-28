//
//  ProfileCoordinator.swift
//  Coco
//
//  Created by Jackie Leonardy on 01/07/25.
//

import Foundation
import UIKit

final class ProfileCoordinator: BaseCoordinator {
    override func start() {
        super.start()
        let viewModel = ProfileViewModel()
        let viewController = ProfileViewController(viewModel: viewModel)
        start(viewController: viewController)
    }
}
