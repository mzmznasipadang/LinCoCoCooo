//
//  HomeFormScheduleViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation

struct HomeFormScheduleViewModelInput {
    let package: ActivityDetailDataModel
    let selectedPackageId: Int
}

final class HomeFormScheduleViewModel {
    weak var delegate: (any HomeFormScheduleViewModelDelegate)?
    weak var actionDelegate: (any HomeFormScheduleViewModelAction)?
    
    init(input: HomeFormScheduleViewModelInput, fetcher: CreateBookingFetcherProtocol = CreateBookingFetcher()) {
        self.input = input
        self.fetcher = fetcher
    }
    
    private let input: HomeFormScheduleViewModelInput
    private lazy var calendarInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "Input Date Visit...",
        currentTypedText: "", // For making sure that the minimum pax is 1 person
        trailingIcon: (
            image: CocoIcon.icFilterIcon.image,
            didTap: openCalendar
        ),
        isTypeAble: false,
        delegate: self
    )
    private lazy var paxInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "Input total Pax...",
        currentTypedText: "1", // For making sure that the minimum pax is 1 person
        trailingIcon: nil,
        isTypeAble: true,
        delegate: self,
        keyboardType: .numberPad
    )
    private var chosenDateInput: Date? {
        didSet {
            guard let chosenDateInput else { return }
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM, yyyy"
            calendarInputViewModel.currentTypedText = dateFormatter.string(from: chosenDateInput)
        }
    }
    private let fetcher: CreateBookingFetcherProtocol
}

extension HomeFormScheduleViewModel: HomeFormScheduleViewModelProtocol {
    func onViewDidLoad() {
        actionDelegate?.setupView(
            calendarViewModel: calendarInputViewModel,
            paxInputViewModel: paxInputViewModel
        )
        
        let data: HomeFormScheduleViewData = HomeFormScheduleViewData(
            imageString: input.package.imageUrlsString.first ?? "",
            activityName: input.package.title,
            packageName: input.package.availablePackages.content.first { $0.id == input.selectedPackageId }?.name ?? "",
            location: input.package.location
        )
        
        actionDelegate?.configureView(data: data)
    }
    
    func onCalendarDidChoose(date: Date) {
        chosenDateInput = date
    }
    
    func onCheckout() {
        // Filtering numeric only in Pax Field
        let currentPaxText = paxInputViewModel.currentTypedText
            let sanitizedPaxText = currentPaxText.filter { "0123456789".contains($0) }
        let finalPaxText = sanitizedPaxText.isEmpty ? "1" : sanitizedPaxText
            paxInputViewModel.currentTypedText = finalPaxText
        let participants = Int(finalPaxText) ?? 1
        
        Task {
            do {
                let request: CreateBookingSpec = CreateBookingSpec(
                    packageId: input.selectedPackageId,
                    bookingDate: chosenDateInput ?? Date(),
                    participants: Int(paxInputViewModel.currentTypedText) ?? 1,
                    userId: UserDefaults.standard.value(forKey: "user-id") as? String ?? ""
                )

                let response: CreateBookingResponse = try await fetcher.createBooking(request: request)
                delegate?.notifyFormScheduleDidNavigateToCheckout(with: response)
            }
            catch {
                print("Booking creation failed: \(error)")
            }
        }
    }
}

extension HomeFormScheduleViewModel: HomeSearchBarViewModelDelegate {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        if viewModel === calendarInputViewModel {
            actionDelegate?.showCalendarOption()
        }
        else if viewModel === paxInputViewModel {
            
        }
    }
}

private extension HomeFormScheduleViewModel {
    func openCalendar() {
        
    }
}
