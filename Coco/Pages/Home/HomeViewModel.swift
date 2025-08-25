//
//  HomeViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Combine
import Foundation

final class HomeViewModel {
    weak var actionDelegate: (any HomeViewModelAction)?
    weak var navigationDelegate: (any HomeViewModelNavigationDelegate)?
    
    init(activityFetcher: ActivityFetcherProtocol = ActivityFetcher()) {
        self.activityFetcher = activityFetcher
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    private let activityFetcher: ActivityFetcherProtocol
    private(set) lazy var loadingState: HomeLoadingState = HomeLoadingState()
    private(set) lazy var searchBarViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: CocoIcon.icSearchLoop.image,
        placeholderText: "Search...",
        currentTypedText: "",
        trailingIcon: (
            image: CocoIcon.icFilterIcon.image,
            didTap: openFilterTray
        ),
        isTypeAble: false,
        delegate: self
    )
    
    private var responseMap: [Int: Activity] = [:]
    private var responseData: [Activity] = []
    private var cancellables: Set<AnyCancellable> = Set()
    
    private(set) var filterDataModel: HomeSearchFilterTrayDataModel?
}

extension HomeViewModel: HomeViewModelProtocol {
    func onViewDidLoad() {
        actionDelegate?.constructLoadingState(state: loadingState)
        actionDelegate?.constructNavBar(viewModel: searchBarViewModel)
        
        fetch()
    }
    
    func onSearchDidApply(_ queryText: String) {
        searchBarViewModel.currentTypedText = queryText
        loadingState.percentage = 0
        actionDelegate?.toggleLoadingView(isShown: true, after: 0)
        fetch()
    }
    
    func onActivityDidSelect(with id: Int) {
        print("🔍 HomeViewModel: Looking for activity with ID: \(id)")
        print("🔍 HomeViewModel: Available IDs in responseMap: \(Array(responseMap.keys).sorted())")
        guard let activity = responseMap[id] else {
            print("❌ HomeViewModel: Activity with ID \(id) not found in responseMap")
            return
        }
        print("✅ HomeViewModel: Found activity: \(activity.title)")
        let data = ActivityDetailDataModel(activity)
        actionDelegate?.activityDidSelect(data: data)
    }
}

extension HomeViewModel: HomeSearchBarViewModelDelegate {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        guard !isTypeAble else { return }
        
        // TODO: Change with real data
        actionDelegate?.openSearchTray(
            selectedQuery: searchBarViewModel.currentTypedText,
            latestSearches: [
                .init(id: 1, name: "Kepulauan Seribu"),
                .init(id: 2, name: "Nusa Penida"),
                .init(id: 3, name: "Gili Island, Indonesia")
            ]
        )
    }
}

private extension HomeViewModel {
    func fetch() {
        activityFetcher.fetchActivity(
            request: ActivitySearchRequest(pSearchText: searchBarViewModel.currentTypedText)
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                print("🟦 HomeViewModel: Fetched \(response.values.count) activities")
                self.loadingState.percentage = 100
                self.actionDelegate?.toggleLoadingView(isShown: false, after: 1.0)
                
                var sectionData: [HomeActivityCellDataModel] = []
                response.values.forEach {
                    print("🟦 HomeViewModel: Adding activity ID \($0.id) to responseMap")
                    sectionData.append(HomeActivityCellDataModel(activity: $0))
                    self.responseMap[$0.id] = $0
                }
                responseData = response.values
                print("🟦 HomeViewModel: Final responseMap contains \(self.responseMap.count) activities")
                self.actionDelegate?.displayActivities(data: sectionData)
                
                contructFilterData()
                
            case .failure(let _error):
                break
            }
        }
    }
    
    func contructFilterData() {
        let responseMapActivity: [Activity] = Array(responseMap.values)
        var seenIDs: Set<Int> = Set()
        var activityValues: [HomeSearchFilterPillState] = responseMap.values
            .flatMap { $0.accessories }
            .filter { accessory in
                if seenIDs.contains(accessory.id) {
                    return false
                } else {
                    seenIDs.insert(accessory.id)
                    return true
                }
            }
            .map {
                HomeSearchFilterPillState(
                    id: $0.id,
                    title: $0.name,
                    isSelected: false
                )
            }
        
        if responseMapActivity.first(where: { !$0.cancelable.isEmpty }) != nil {
            activityValues.append(
                HomeSearchFilterPillState(
                    id: -99999999,
                    title: "Free Cancellation",
                    isSelected: false
                )
            )
        }
        
        let sortedData = responseMapActivity.sorted { $0.pricing < $1.pricing }
        
        let minPrice: Double = sortedData.first?.pricing ?? 0
        let maxPrice: Double = sortedData.last?.pricing ?? 0
        let filterDataModel: HomeSearchFilterTrayDataModel = HomeSearchFilterTrayDataModel(
            filterPillDataState: activityValues,
            priceRangeModel: HomeSearchFilterPriceRangeModel(
                minPrice: minPrice,
                maxPrice: maxPrice,
                range: minPrice...maxPrice,
                step: 10000
            )
        )
        
        self.filterDataModel = filterDataModel
    }
    
    func openFilterTray() {
        guard let filterDataModel: HomeSearchFilterTrayDataModel else { return }
        
        let viewModel: HomeSearchFilterTrayViewModel = HomeSearchFilterTrayViewModel(
            dataModel: filterDataModel,
            activities: Array(responseMap.values)
        )
        viewModel.filterDidApplyPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] newFilterData in
                guard let self else { return }
                self.filterDataModel = newFilterData
                actionDelegate?.dismissTray()
                filterDidApply()
            }
            .store(in: &cancellables)
        
        actionDelegate?.openFilterTray(viewModel)
    }
    
    func filterDidApply() {
        guard let filterDataModel: HomeSearchFilterTrayDataModel else { return }
        let tempResponseData: [Activity] = HomeFilterUtil.doFilter(
            responseData,
            filterDataModel: filterDataModel
        )
        
        let activitiesData = tempResponseData.map {
            HomeActivityCellDataModel(activity: $0)
        }
        actionDelegate?.displayActivities(data: activitiesData)
    }
}
