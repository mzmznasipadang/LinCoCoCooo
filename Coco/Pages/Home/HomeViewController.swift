//
//  HomeViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 02/07/25.
//

import Foundation
import SwiftUI
import UIKit

enum HomeSection {
    case promo(images: [String])
    case activity(title: String, activities: [HomeActivityCellDataModel])
}

final class HomeViewController: UIViewController {
    var coordinator: HomeCoordinator? // Changed from weak to strong
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
    private var sections: [HomeSection] = []
}

private extension HomeViewController {
    func setupCollectionView() {
        thisView.collectionView.delegate = self
        thisView.collectionView.dataSource = self
        thisView.collectionView.register(PromoSectionCell.self, forCellWithReuseIdentifier: PromoSectionCell.reuseIdentifier)
        thisView.collectionView.register(HomeActivityCell.self, forCellWithReuseIdentifier: "HomeActivityCell")
        thisView.collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeader"
        )
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
        
        var newSections: [HomeSection] = []
        
        // Family
        if let familyActivities = groupedActivities["Family"] {
            newSections.append(.activity(title: "Perfect for Family", activities: familyActivities))
        }
        
        // Promo
        let promoImageNames = ["Banner1", "Banner2", "Banner3", "Banner4"]
        newSections.append(.promo(images: promoImageNames))
        
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
            newSections.append(.activity(title: "Popular Activities", activities: popularActivities))
        }
        if !nearActivities.isEmpty {
            newSections.append(.activity(title: "Near You", activities: nearActivities))
        }
        if !newActivities.isEmpty {
            newSections.append(.activity(title: "Newly Added", activities: newActivities))
        }
        
        self.sections = newSections
        
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
        guard let navigationController = navigationController else { return }
        
        let homeCoordinator = HomeCoordinator(input: .init(
            navigationController: navigationController,
            flow: .activityDetail(data: data)
        ))
        self.coordinator = homeCoordinator
        homeCoordinator.start()
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
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .promo:
            return 1
        case .activity(_, let activities):
            return activities.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        
        switch section {
        case .promo(let images):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PromoSectionCell.reuseIdentifier, for: indexPath) as? PromoSectionCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: images)
            return cell
            
        case .activity(_, let activities):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeActivityCell", for: indexPath) as? HomeActivityCell else {
                return UICollectionViewCell()
            }
            let activity = activities[indexPath.item]
            cell.configureCell(activity)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "SectionHeader",
                for: indexPath) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        
        let section = sections[indexPath.section]
        let title: String
        switch section {
        case .promo:
            title = "Promo"
        case .activity(let sectionTitle, _):
            title = sectionTitle
        }
        header.configure(with: title)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = sections[indexPath.section]
        let padding: CGFloat = 16
        let width = (collectionView.frame.width - padding * 3) / 2
        return CGSize(width: width, height: width + 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionType = sections[section]
        
        switch sectionType {
        case .promo:
            return UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
            
        case .activity:
            let padding: CGFloat = 16
            return UIEdgeInsets(top: 8, left: padding, bottom: 8, right: padding)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        if case .activity(_, let activities) = section {
            let selectedActivity = activities[indexPath.item]
            viewModel.onActivityDidSelect(with: selectedActivity.id)
        }
    }
}

final class PromoSectionCell: UICollectionViewCell {
    static let reuseIdentifier = "PromoSectionCell"
    
    private let scrollView = UIScrollView()
    private let imageStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageStackView)
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        
        imageStackView.axis = .horizontal
        imageStackView.spacing = 16
        imageStackView.alignment = .center
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            imageStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0),
            imageStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0),
            imageStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    func configure(with imageNames: [String]) {
        imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for imageName in imageNames {
            let imageView = UIImageView()
            imageView.image = UIImage(named: imageName)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 8
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 280),
                imageView.heightAnchor.constraint(equalToConstant: 160)
            ])
            
            imageStackView.addArrangedSubview(imageView)
        }
    }
}
