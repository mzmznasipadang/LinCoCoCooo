//
//  MockActivityDetailViewModel.swift
//  Coco
//
//  Created by Lin Dan Christiano on 20/08/25.
//

import Foundation
@testable import Coco

final class MockActivityDetailViewModel: ActivityDetailViewModelProtocol {

    weak var actionDelegate: ActivityDetailViewModelAction?
    weak var navigationDelegate: ActivityDetailNavigationDelegate?

    private(set) var didCallOnViewDidLoad = 0
    func onViewDidLoad() { didCallOnViewDidLoad += 1 }

    private(set) var didCallOnPackagesDetailDidTap: [Int] = []
    func onPackagesDetailDidTap(with packageId: Int) {
        didCallOnPackagesDetailDidTap.append(packageId)
    }
}

// MockAction
final class MockActivityDetailViewModelAction: ActivityDetailViewModelAction {
    private(set) var configureViewCount = 0
    private(set) var lastConfiguredData: ActivityDetailDataModel?
    func configureView(data: ActivityDetailDataModel) {
        configureViewCount += 1; lastConfiguredData = data
    }

    private(set) var updatePackageDataCount = 0
    private(set) var lastPackages: [ActivityDetailDataModel.Package] = []
    func updatePackageData(data: [ActivityDetailDataModel.Package]) {
        updatePackageDataCount += 1; lastPackages = data
    }
}

// MockNav
final class MockActivityDetailViewModelNavigationDelegate: ActivityDetailNavigationDelegate {
    private(set) var invokedCount = 0
    private(set) var lastPackage: ActivityDetailDataModel?
    private(set) var lastId: Int?
    func notifyActivityDetailPackageDidSelect(package: ActivityDetailDataModel, selectedPackageId: Int) {
        invokedCount += 1; lastPackage = package; lastId = selectedPackageId
    }
}

