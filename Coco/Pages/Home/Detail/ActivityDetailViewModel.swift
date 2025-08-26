//
//  ActivityDetailViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation

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
        navigationDelegate?.notifyActivityDetailPackageDidSelect(package: data, selectedPackageId: packageId)
    }
}
