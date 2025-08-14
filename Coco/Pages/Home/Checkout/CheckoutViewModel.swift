//
//  CheckoutViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation

final class CheckoutViewModel {
    weak var delegate: (any CheckoutViewModelDelegate)?
    weak var actionDelegate: (any CheckoutViewModelAction)?
    init(
        package: ActivityDetailDataModel,
        selectedPackageId: Int,
        bookingDate: Date,
        participants: Int,
        userId: String,
        fetcher: CreateBookingFetcherProtocol = CreateBookingFetcher()
    ) {
        self.package = package
        self.selectedPackageId = selectedPackageId
        self.bookingDate = bookingDate
        self.participants = participants
        self.userId = userId
        self.fetcher = fetcher
    }
    
    private let package: ActivityDetailDataModel
    private let selectedPackageId: Int
    private let bookingDate: Date
    private let participants: Int
    private let userId: String
    private let fetcher: CreateBookingFetcherProtocol
    
    private lazy var idrNoCentsFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "id_ID")
        f.numberStyle = .currency
        f.currencyCode = "IDR"
        f.maximumFractionDigits = 0
        return f
    }()
}

extension CheckoutViewModel: CheckoutViewModelProtocol {
    func onViewDidLoad() {
        let selectedPackage = package.availablePackages.content.first { $0.id == selectedPackageId }
        
        let df = DateFormatter()
        df.locale = Locale(identifier: "id_ID")
        df.dateFormat = "dd MMMM, yyyy"
        
        let priceText: String? = selectedPackage?.price
        
        let display = CheckoutDisplayData(
            imageUrl: package.imageUrlsString.first,
            activityTitle: package.title,
            packageName: selectedPackage?.name ?? "",
            destinationName: package.location,
            participantsText: "\(participants) Participants",
            dateText: df.string(from: bookingDate),
            totalPriceText: priceText
        )
        
        actionDelegate?.configureView(bookingData: display)
    }
    
    func bookNowDidTap() {
        actionDelegate?.setLoading(true)

        Task {
            do {
                let request = CreateBookingSpec(
                    packageId: selectedPackageId,
                    bookingDate: bookingDate,
                    participants: participants,
                    userId: userId
                )

                let _ = try await fetcher.createBooking(request: request)

                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.actionDelegate?.setLoading(false)
                    self.actionDelegate?.showPopUpSuccess(completion: { [weak self] in
                        self?.delegate?.notifyUserDidCheckout()
                    })
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.actionDelegate?.setLoading(false)
                    self?.actionDelegate?.showError(message: "Terjadi kesalahan saat membuat booking. Coba lagi.")
                }
            }
        }
    }
}
