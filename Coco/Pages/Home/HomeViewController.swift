//
//  HomeViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 02/07/25.
//

import Foundation
import SwiftUI
import UIKit

struct ActivitySection {
    let title: String
    let activities: [HomeActivityCellDataModel]
}

final class HomeViewController: UIViewController {
    init(viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = thisView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        viewModel.onViewDidLoad()
    }
    
    private let thisView: HomeView = HomeView()
    private let viewModel: HomeViewModelProtocol
    private var activitySections: [ActivitySection] = []
}

private extension HomeViewController {
    func setupCollectionView() {
        thisView.collectionView.delegate = self
        thisView.collectionView.dataSource = self
    }
    
    func presentTray(view: some View) {
        let trayVC: UIHostingController = UIHostingController(rootView: view)
        if let sheet: UISheetPresentationController = trayVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.preferredCornerRadius = 32.0
        }
        present(trayVC, animated: true)
    }
}

extension HomeViewController: HomeViewModelAction {
    func displayActivities(data: [HomeActivityCellDataModel]) {
        let groupedActivities = Dictionary(grouping: data) { activity -> String in
            let adtData = AdditionalDataService.shared.getActivity(byId: activity.id)
            return adtData?.label ?? "Other"
        }
        
        var newActivitySections: [ActivitySection] = []
        
        // Family
        if let familyActivities = groupedActivities["Family"] {
            newActivitySections.append(ActivitySection(title: "Perfect for Family", activities: familyActivities))
        }
        
        // Dummy data: popularity, nearby, new
        var popularActivities: [HomeActivityCellDataModel] = []
        var nearActivities: [HomeActivityCellDataModel] = []
        var newActivities: [HomeActivityCellDataModel] = []
        
        let otherSections = ["Couples", "Group", "Solo"]
        let combinedActivities = otherSections.flatMap { groupedActivities[$0] ?? [] }
        
        for (index, activity) in combinedActivities.enumerated() {
            switch index % 3 {
            case 0:
                popularActivities.append(activity)
            case 1:
                nearActivities.append(activity)
            default:
                newActivities.append(activity)
            }
        }
        
        if !popularActivities.isEmpty {
            newActivitySections.append(ActivitySection(title: "Popular Activities", activities: popularActivities))
        }
        if !nearActivities.isEmpty {
            newActivitySections.append(ActivitySection(title: "Near You", activities: nearActivities))
        }
        if !newActivities.isEmpty {
            newActivitySections.append(ActivitySection(title: "Newly Added", activities: newActivities))
        }
        
        self.activitySections = newActivitySections
        
        DispatchQueue.main.async {
            self.thisView.collectionView.reloadData()
        }
    }
    
    func constructLoadingState(state: HomeLoadingState) {
        let viewController: UIHostingController = UIHostingController(rootView: HomeLoadingView(state: state))
        addChild(viewController)
        thisView.addLoadingView(from: viewController.view)
        viewController.didMove(toParent: self)
        
        thisView.toggleLoadingView(isShown: true)
    }
    
    func constructNavBar(viewModel: HomeSearchBarViewModel) {
        let viewController: HomeSearchBarHostingController = HomeSearchBarHostingController(viewModel: viewModel)
        addChild(viewController)
        thisView.addSearchBarView(from: viewController.view)
        viewController.didMove(toParent: self)
    }
    
    func toggleLoadingView(isShown: Bool, after: CGFloat) {
        DispatchQueue.main.asyncAfter(deadline: .now() + after, execute: { [weak self] in
            guard let self else { return }
            self.thisView.toggleLoadingView(isShown: isShown)
        })
    }
    
    func activityDidSelect(data: ActivityDetailDataModel) {
        let detailViewModel = ActivityDetailViewModel(data: data)
        let detailViewController = ActivityDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func openSearchTray(
        selectedQuery: String,
        latestSearches: [HomeSearchSearchLocationData]
    ) {
        presentTray(view: HomeSearchSearchTray(
            selectedQuery: selectedQuery,
            latestSearches: latestSearches
        ) { [weak self] queryText in
            self?.dismiss(animated: true)
            self?.viewModel.onSearchDidApply(queryText)
        })
    }
    
    func openFilterTray(_ viewModel: HomeSearchFilterTrayViewModel) {
        presentTray(view: HomeSearchFilterTray(viewModel: viewModel))
    }
    
    func dismissTray() {
        dismiss(animated: true)
    }
}

// Grouped Trip
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return activitySections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activitySections[section].activities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeActivityCell", for: indexPath) as? HomeActivityCell else {
            return UICollectionViewCell()
        }
        let activity = activitySections[indexPath.section].activities[indexPath.item]
        cell.configureCell(activity)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "SectionHeader",
                for: indexPath) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        
        let section = activitySections[indexPath.section]
        header.configure(with: section.title)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedActivity = activitySections[indexPath.section].activities[indexPath.item]
        viewModel.onActivityDidSelect(with: selectedActivity.id)
    }
}
