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
    
    init(input: HomeFormScheduleViewModelInput, fetcher: CreateBookingFetcherProtocol = CreateBookingFetcher(), activityFetcher: ActivityFetcherProtocol = ActivityFetcher()) {
        self.input = input
        self.fetcher = fetcher
        self.activityFetcher = activityFetcher
    }
    
    private let input: HomeFormScheduleViewModelInput
    private lazy var calendarInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "Input Date Visit...",
        currentTypedText: "",
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
        currentTypedText: "",
        trailingIcon: nil,
        isTypeAble: true,
        delegate: self
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
    
    private let activityFetcher: ActivityFetcherProtocol
    
    private var minPax: Int?
    private var maxPax: Int?
}

extension HomeFormScheduleViewModel: HomeFormScheduleViewModelProtocol {
    func refreshPaxPlaceholder() {
        let text: String
        switch (minPax, maxPax) {
        case let (min?, max?):
            text = "Input total Pax... \(min) - \(max) Person(s)"
        case let (min?, nil):
            text = "Input total Pax... min \(min) Person(s)"
        case let (nil, max?):
            text = "Input total Pax... up to \(max) Person(s)"
        default:
            text = "Input total Pax..."
        }
        
        paxInputViewModel.placeholderText = text
    }
    
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
        
        if let selected = input.package.availablePackages.content.first(where: { $0.id == input.selectedPackageId }) {
            self.minPax = selected.minParticipants
            self.maxPax = selected.maxParticipants
            self.refreshPaxPlaceholder()
        }
        
        activityFetcher.fetchPackageDetail(packageId: input.selectedPackageId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let pkg):
                self.minPax = pkg.minParticipants
                self.maxPax = pkg.maxParticipants
                self.refreshPaxPlaceholder()
            case .failure(let err):
                print("fetchPackageDetail error:", err)
            }
        }

    }
    
    func onCalendarDidChoose(date: Date) {
        chosenDateInput = date
    }
    
    func onCheckout() {
        let raw = paxInputViewModel.currentTypedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else {
            actionDelegate?.showValidationError(message: "Masukkan jumlah orang terlebih dahulu.")
            return
        }
        guard let participants = Int(raw), participants > 0 else {
            actionDelegate?.showValidationError(message: "Jumlah orang harus berupa angka yang valid.")
            return
        }

        guard minPax != nil || maxPax != nil else {
            actionDelegate?.showValidationError(message: "Tidak dapat memuat batas peserta paket. Coba lagi memilih paket atau periksa koneksi.")
            return
        }

        if let min = minPax, participants < min {
            actionDelegate?.showValidationError(message: "Minimal peserta untuk paket ini adalah \(min) orang.")
            return
        }
        if let max = maxPax, participants > max {
            actionDelegate?.showValidationError(message: "Maksimal peserta untuk paket ini adalah \(max) orang.")
            return
        }

        let bookingDate = chosenDateInput ?? Date()
        let userId = UserDefaults.standard.value(forKey: "user-id") as? String ?? ""

        delegate?.notifyFormScheduleDidNavigateToCheckout(
            package: input.package,
            selectedPackageId: input.selectedPackageId,
            bookingDate: bookingDate,
            participants: participants,
            userId: userId
        )
    }
}

extension HomeFormScheduleViewModel: HomeSearchBarViewModelDelegate {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        if viewModel === calendarInputViewModel {
            actionDelegate?.showCalendarOption()
        } else if viewModel === paxInputViewModel {
            
        }
    }
}

private extension HomeFormScheduleViewModel {
    func openCalendar() {
        
    }
}
