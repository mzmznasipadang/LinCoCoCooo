//
//  CheckoutViewModelContract.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation

struct CheckoutDisplayData {
    let imageUrl: String?
    let activityTitle: String
    let packageName: String
    let destinationName: String
    let participantsText: String
    let dateText: String
    let totalPriceText: String?
}

protocol CheckoutViewModelDelegate: AnyObject {
    func notifyUserDidCheckout()
}

protocol CheckoutViewModelAction: AnyObject {
    func configureView(bookingData: CheckoutDisplayData)
    func showPopUpSuccess(completion: @escaping () -> Void)
    
    func setLoading(_ isLoading: Bool)
    func showError(message: String)
}

protocol CheckoutViewModelProtocol: AnyObject {
    var delegate: CheckoutViewModelDelegate? { get set }
    var actionDelegate: CheckoutViewModelAction? { get set }
    init(
        package: ActivityDetailDataModel,
        selectedPackageId: Int,
        bookingDate: Date,
        participants: Int,
        userId: String,
        fetcher: CreateBookingFetcherProtocol
    )
    
    func onViewDidLoad()
    func bookNowDidTap()
}
